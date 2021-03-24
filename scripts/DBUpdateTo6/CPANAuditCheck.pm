# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# Copyright (C) 2021 Centuran Consulting, https://centuran.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package scripts::DBUpdateTo6::CPANAuditCheck;    ## no critic

use strict;
use warnings;

use parent qw(scripts::DBUpdateTo6::Base);

our @ObjectDependencies = (
    'Kernel::System::Cache',
    'Kernel::System::Console::Command::Dev::Code::CPANAudit',
    'Kernel::System::Main',
    'Kernel::System::SysConfig',
);

=head1 NAME

scripts::DBUpdateTo6::CPANAuditCheck - Checks for CPAN::Audit warnings.

=cut

sub Run {
    my ( $Self, %Param ) = @_;

    my $CommandObject = $Kernel::OM->Get('Kernel::System::Console::Command::Dev::Code::CPANAudit');

    my ( $CommandOutput, $ExitCode );

    {
        local *STDOUT;
        open STDOUT, '>:utf8', \$CommandOutput;    ## no critic
        $ExitCode = $CommandObject->Execute();
    }

    if ( $ExitCode != 0 ) {
        print $CommandOutput;
        print
            "\n    WARNING: CPAN::Audit reported that one or more installed CPAN modules have known vulnerabilities (see above). Please note that there might be false positives for distributions patching Perl modules without changing their version number.\n\n";
    }
    elsif ( $Param{CommandlineOptions}->{Verbose} ) {
        print $CommandOutput;
    }

    # Always return success, as warnings generated by this module are not considered fatal.
    return 1;
}

1;
