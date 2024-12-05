# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# Copyright (C) 2021-2023 Centuran Consulting, https://centuran.com/
# Includes AGPL-licensed work by:
# Copyright (C) 2021-2022 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed files COPYING and COPYING-AGPL for license information (GPL
# and AGPL). If you did not receive these files, see
# https://www.gnu.org/licenses/gpl-3.0.txt and
# https://www.gnu.org/licenses/agpl-3.0.txt.
# --

package Kernel::System::MailAccount::IMAP;

use strict;
use warnings;

use Mail::IMAPClient;

use parent 'Kernel::System::MailAccount::Base';

use Kernel::System::PostMaster;
use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::CommunicationLog',
    'Kernel::System::Log',
    'Kernel::System::Main',
    'Kernel::System::OAuth2Token',
);

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = $Type->SUPER::new(%Param);
    bless($Self, $Type);

    $Self->{FullModuleName} = __PACKAGE__;
    $Self->{ModuleName}     = __PACKAGE__ =~ s/.*:://r;

    return $Self;
}

sub Connect {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for my $Name (qw(Login Host Timeout Debug)) {
        if ( !defined $Param{$Name} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Name!"
            );
            return (
                Successful => 0,
                Message    => "Need $Name!",
            );
        }
    }

    my %IMAPClientParams = (
        Server => $Param{Host},
        User   => $Param{Login},
        Debug  => $Param{Debug},
        Uid    => 1,

        %{$Self->{_SSLOptions}},
        %{$Self->{_StartTLSOptions}},

        Ignoresizeerrors => 1,
    );

    my $AuthMethod = $Param{AuthenticationMethod} // 'password';

    if ( $AuthMethod eq 'password' ) {
        if ( !defined $Param{Password} ) {
            return (
                Successful => 0,
                Message    => 'Need Password!',
            );
        }

        $IMAPClientParams{Password} = $Param{Password};
    }
    elsif ( $AuthMethod eq  'oauth2_token' ) {
        if ( !defined $Param{OAuth2TokenConfigID} ) {
            return (
                Successful => 0,
                Message    => 'Need OAuth2TokenConfigID!',
            );
        }
    }
    else {
        return (
            Successful => 0,
            Message    => "Authentication method $AuthMethod is not supported.",
        );
    }

    my $IMAPClient = Mail::IMAPClient->new(%IMAPClientParams);

    if ( !$IMAPClient ) {
        return (
            Successful => 0,
            Message    => "$Self->{ModuleName}: Can't connect to " .
                "$Param{Host} ($@)."
        );
    }

    if ( $AuthMethod eq 'oauth2_token' ) {
        my $OAuth2TokenObject = $Kernel::OM->Get('Kernel::System::OAuth2Token');

        my $Token = $OAuth2TokenObject->GetToken(
            ConfigID => $Param{OAuth2TokenConfigID},
            UserID   => 1,
        );

        if ( !$Token ) {
            return (
                Successful => 0,
                Message    => 'Failed to retrieve OAuth2 token.',
            );
        }

        my $SASLAuthString = $OAuth2TokenObject->GetSASLAuthString(
            Username    => $Param{Login},
            OAuth2Token => $Token,
        );

        if ( !$IMAPClient->authenticate('XOAUTH2',
            sub { return $SASLAuthString }) )
        {
            return (
                Successful => 0,
                Message    => 'Authentication failed: ' .
                    $IMAPClient->LastError(),
            );
        }
    }

    return (
        Successful => 1,
        IMAPObject => $IMAPClient,
        Type       => $Self->{ModuleName},
    );
}

sub Fetch {
    my ( $Self, %Param ) = @_;

    # start a new incoming communication
    my $CommunicationLogObject = $Kernel::OM->Create(
        'Kernel::System::CommunicationLog',
        ObjectParams => {
            Transport   => 'Email',
            Direction   => 'Incoming',
            AccountType => $Param{Type},
            AccountID   => $Param{ID},
        },
    );

    # fetch again if still messages on the account
    my $CommunicationLogStatus = 'Successful';
    COUNT:
    for my $Number ( 1 .. 200 ) {
        my $Fetch = $Self->_Fetch(
            %Param,
            CommunicationLogObject => $CommunicationLogObject,
        );
        if ( !$Fetch ) {
            $CommunicationLogStatus = 'Failed';
        }

        last COUNT if !$Self->{Reconnect};
    }

    $CommunicationLogObject->CommunicationStop(
        Status => $CommunicationLogStatus,
    );

    return 1;
}

sub _Fetch {
    my ( $Self, %Param ) = @_;

    my $CommunicationLogObject = $Param{CommunicationLogObject};

    $CommunicationLogObject->ObjectLogStart(
        ObjectLogType => 'Connection',
    );

    # check needed stuff
    for my $Name (qw(Login Password Host Trusted QueueID)) {
        if ( !defined $Param{$Name} ) {
            $CommunicationLogObject->ObjectLog(
                ObjectLogType => 'Connection',
                Priority      => 'Error',
                Key           => $Self->{FullModuleName},
                Value         => "$Name not defined!",
            );

            $CommunicationLogObject->ObjectLogStop(
                ObjectLogType => 'Connection',
                Status        => 'Failed',
            );

            $CommunicationLogObject->CommunicationStop(
                Status => 'Failed'
            );

            return;
        }
    }
    for my $Name (qw(Login Password Host)) {
        if ( !$Param{$Name} ) {
            $CommunicationLogObject->ObjectLog(
                ObjectLogType => 'Connection',
                Priority      => 'Error',
                Key           => $Self->{FullModuleName},
                Value         => "Need $Name!",
            );

            $CommunicationLogObject->ObjectLogStop(
                ObjectLogType => 'Connection',
                Status        => 'Failed',
            );

            $CommunicationLogObject->CommunicationStop(
                Status => 'Failed'
            );

            return;
        }
    }

    my $Debug = $Param{Debug} || 0;
    my $Limit = $Param{Limit} || 5000;
    my $CMD   = $Param{CMD}   || 0;

    # get config object
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # MaxEmailSize
    my $MaxEmailSize = $ConfigObject->Get('PostMasterMaxEmailSize') || 1024 * 6;

    # MaxPopEmailSession
    my $MaxPopEmailSession = $ConfigObject->Get('PostMasterReconnectMessage') || 20;

    my $Timeout      = 60;
    my $FetchCounter = 0;

    $Self->{Reconnect} = 0;

    $CommunicationLogObject->ObjectLog(
        ObjectLogType => 'Connection',
        Priority      => 'Debug',
        Key           => $Self->{FullModuleName},
        Value         => "Open connection to '$Param{Host}' ($Param{Login}).",
    );

    my %Connect;
    eval {
        %Connect = $Self->Connect(
            Host                 => $Param{Host},
            Login                => $Param{Login},
            AuthenticationMethod => $Param{AuthenticationMethod},
            Password             => $Param{Password},
            OAuth2TokenConfigID  => $Param{OAuth2TokenConfigID},
            Timeout              => $Timeout,
            Debug                => $Debug
        );
    } || do {
        my $Error = $@;
        %Connect = (
            Successful => 0,
            Message => 'Something went wrong while trying to connect to ' .
                "'$Self->{ModuleName} => $Param{Login}/$Param{Host}': " .
                "${ Error }",
        );
    };

    if ( !$Connect{Successful} ) {
        $CommunicationLogObject->ObjectLog(
            ObjectLogType => 'Connection',
            Priority      => 'Error',
            Key           => $Self->{FullModuleName},
            Value         => $Connect{Message},
        );

        $CommunicationLogObject->ObjectLogStop(
            ObjectLogType => 'Connection',
            Status        => 'Failed',
        );

        $CommunicationLogObject->CommunicationStop(
            Status => 'Failed'
        );

        return;
    }

    my $IMAPOperation = sub {
        my $Operation = shift;
        my @Params    = @_;

        my $IMAPObject = $Connect{IMAPObject};
        my $ScalarResult;
        my @ArrayResult = ();
        my $Wantarray   = wantarray;

        eval {
            if ($Wantarray) {
                @ArrayResult = $IMAPObject->$Operation( @Params, );
            }
            else {
                $ScalarResult = $IMAPObject->$Operation( @Params, );
            }

            return 1;
        } || do {
            my $Error = $@;
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => sprintf(
                    "Error while executing '%s->%s(%s)': %s",
                    $Self->{ModuleName},
                    $Operation,
                    join( ',', @Params ),
                    $Error,
                ),
            );
        };

        return @ArrayResult if $Wantarray;
        return $ScalarResult;
    };

    my $IMAPFolder = $Param{IMAPFolder} || 'INBOX';
    my $MessageCount = 0;
    my $Messages;

    my $ConnectionWithErrors = 0;
    my $MessagesWithError    = 0;

    eval {
        $IMAPOperation->('select', $IMAPFolder)
            or die "Select failed: $@\n";

        $Messages = $IMAPOperation->('messages')
            or die "Failed to retrieve messages: $@\n";

        if ( IsArrayRefWithData($Messages) ) {
            $MessageCount = scalar @$Messages;
        }

        if ( $CMD ) {
            print "$Self->{ModuleName}: Found $MessageCount messages on " .
                "$Param{Login}/$Param{Host}.\n";
        }

        return 1;
    }
    or do {
        my $Error = $@;
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => sprintf(
                "Error while retrieving messages '%s': %s",
                $Self->{ModuleName},
                $Error,
            ),
        );

        $ConnectionWithErrors = 1;
    };

    if ( $MessageCount > 0 ) {
        MESSAGE_NO:
        for my $MessageNo (@$Messages) {

            # check if reconnect is needed
            if ( $FetchCounter >= $MaxPopEmailSession ) {
                $Self->{Reconnect} = 1;

                if ($CMD) {
                    print "$Self->{ModuleName}: Reconnect Session after " .
                        "$MaxPopEmailSession messages...\n";
                }

                last MESSAGE_NO;
            }

            if ($CMD) {
                print "$Self->{ModuleName}: Message $FetchCounter/" .
                    "$MessageCount ($Param{Login}/$Param{Host})\n";
            }

            # check message size
            my $MessageSize = $IMAPOperation->('size', $MessageNo);
            if ( !( defined $MessageSize ) ) {
                my $ErrorMessage = "$Self->{ModuleName}: Can't determine " .
                    "the size of email '$MessageNo/$MessageCount' from " .
                    "$Param{Login}/$Param{Host}!";

                $CommunicationLogObject->ObjectLog(
                    ObjectLogType => 'Connection',
                    Priority      => 'Error',
                    Key           => $Self->{FullModuleName},
                    Value         => $ErrorMessage,
                );

                $ConnectionWithErrors = 1;

                if ($CMD) {
                    print "\n";
                }

                next MESSAGE_NO;
            }

            $MessageSize = int($MessageSize / 1024);

            if ( $MessageSize > $MaxEmailSize ) {
                $CommunicationLogObject->ObjectLog(
                    ObjectLogType => 'Connection',
                    Priority      => 'Error',
                    Key           => $Self->{FullModuleName},
                    Value         => "$Self->{ModuleName}: cannot fetch " .
                        "message $MessageNo/$MessageCount from " .
                        "$Param{Login}/$Param{Host} - message too large " .
                        "($MessageSize KB; maximum allowed size is " .
                        "$MaxEmailSize KB).",
                );

                $ConnectionWithErrors = 1;
                if ($CMD) {
                    print "Skipping: $Self->{ModuleName}: cannot fetch " .
                        "message $MessageNo/$MessageCount from " .
                        "$Param{Login}/$Param{Host} - message too large " .
                        "($MessageSize KB; maximum allowed size is " .
                        "$MaxEmailSize KB)\n\n";
                }
            }
            else {

                $FetchCounter++;
                # safety protection
                my $FetchDelay = ( $FetchCounter % 20 == 0 ? 1 : 0 );
                if ( $FetchDelay && $CMD ) {
                    print "$Self->{ModuleName}: Safety protection: waiting 1 " .
                        "second before processing next mail...\n";

                    sleep 1;
                }

                # get message (header and body)
                my $Message = $IMAPOperation->('message_string', $MessageNo);

                if ( !$Message ) {
                    $CommunicationLogObject->ObjectLog(
                        ObjectLogType => 'Connection',
                        Priority      => 'Error',
                        Key           => $Self->{FullModuleName},
                        Value         => "$Self->{ModuleName}: Message " .
                            "$MessageNo is empty.",
                    );

                    $ConnectionWithErrors = 1;
                }
                else {
                    $CommunicationLogObject->ObjectLog(
                        ObjectLogType => 'Connection',
                        Priority      => 'Debug',
                        Key           => $Self->{FullModuleName},
                        Value         => "Message '$MessageNo' successfully " .
                            'received from server.',
                    );

                    $CommunicationLogObject->ObjectLogStart(
                        ObjectLogType => 'Message'
                    );
                    my $MessageStatus = 'Successful';

                    my $PostMasterObject = Kernel::System::PostMaster->new(
                        %{$Self},
                        Email                  => \$Message,
                        Trusted                => $Param{Trusted} || 0,
                        Debug                  => $Debug,
                        CommunicationLogObject => $CommunicationLogObject,
                    );

                    my @Return = eval {
                        return $PostMasterObject->Run(
                            QueueID => $Param{QueueID} || 0
                        );
                    };
                    my $Exception = $@ || undef;

                    if ( !$Return[0] ) {
                        $MessagesWithError += 1;

                        if ($Exception) {
                            $Kernel::OM->Get('Kernel::System::Log')->Log(
                                Priority => 'error',
                                Message  => 'Exception while processing mail: ' . $Exception,
                            );
                        }

                        # FIXME: Do we need this line?
                        my $Lines = $IMAPOperation->( 'get', $MessageNo, );
                        my $File  = $Self->_ProcessFailed( Email => $Message );

                        $CommunicationLogObject->ObjectLog(
                            ObjectLogType => 'Connection',
                            Priority      => 'Error',
                            Key           => $Self->{FullModuleName},
                            Value         => "$Self->{ModuleName}: Failed to " .
                                "process message (saved as $File).",
                        );

                        $MessageStatus = 'Failed';
                    }

                    $IMAPOperation->('delete_message', $MessageNo);

                    undef $PostMasterObject;

                    $CommunicationLogObject->ObjectLogStop(
                        ObjectLogType => 'Message',
                        Status        => $MessageStatus,
                    );
                }

                # check limit
                $Self->{Limit}++;
                if ( $Self->{Limit} >= $Limit ) {
                    $Self->{Reconnect} = 0;
                    last MESSAGE_NO;
                }
            }

            if ($CMD) {
                print "\n";
            }
        }
    }

    if ( $Debug || $FetchCounter > 0 ) {
        $CommunicationLogObject->ObjectLog(
            ObjectLogType => 'Connection',
            Priority      => 'Info',
            Key           => $Self->{FullModuleName},
            Value         => "$Self->{ModuleName}: Fetched $FetchCounter " .
                "message(s) from $Param{Login}/$Param{Host}.",
        );
    }

    $IMAPOperation->('close');
    if ($CMD) {
        print "$Self->{ModuleName}: Connection to $Param{Host} closed.\n\n";
    }

    if ($ConnectionWithErrors) {
        $CommunicationLogObject->ObjectLogStop(
            ObjectLogType => 'Connection',
            Status        => 'Failed',
        );

        return;
    }

    $CommunicationLogObject->ObjectLogStop(
        ObjectLogType => 'Connection',
        Status        => 'Successful',
    );
    $CommunicationLogObject->CommunicationStop(
        Status => 'Successful',
    );

    return if $MessagesWithError;
    return 1;
}

sub _ProcessFailed {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    if ( !defined $Param{Email} ) {

        my $ErrorMessage = "'Email' not defined!";

        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => $ErrorMessage,
        );
        return;
    }

    my $MainObject = $Kernel::OM->Get('Kernel::System::Main');

    my $Home = $Kernel::OM->Get('Kernel::Config')->Get('Home') . '/var/spool/';
    my $MD5  = $MainObject->MD5sum(
        String => \$Param{Email},
    );
    my $Location = $Home . 'problem-email-' . $MD5;

    return $MainObject->FileWrite(
        Location   => $Location,
        Content    => \$Param{Email},
        Mode       => 'binmode',
        Type       => 'Local',
        Permission => '640',
    );
}

1;
