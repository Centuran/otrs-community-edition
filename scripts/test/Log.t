# --
# Copyright (C) 2024 Centuran Consulting, https://centuran.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

use strict;
use warnings;
use utf8;

use vars (qw($Self));

# Test for the "wide character in shmwrite" error that started occurring
# in Perl 5.34 (irrelevant for earlier versions)
eval {
    my $LogObject = $Kernel::OM->Get('Kernel::System::Log');
    $LogObject->Log(
        Priority => 'info',
        Message  => "\x{1F600}",
    );
};

$Self->Is(
    $@,
    '',
    'No "wide character in shmwrite" error is thrown',
);

1;
