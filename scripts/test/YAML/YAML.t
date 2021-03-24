# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# Copyright (C) 2021 Centuran Consulting, https://centuran.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

## no critic (Modules::RequireExplicitPackage)
use strict;
use warnings;
use utf8;

use Kernel::System::ObjectManager;

use vars (qw($Self));

# get YAML object
my $YAMLObject = $Kernel::OM->Get('Kernel::System::YAML');

my @Tests = (
    {
        Name          => 'Simple string',
        Data          => 'Teststring <tag> äß@ø " \\" \' \'\'',
        SuccessDecode => 1,
    },
    {
        Name => 'Complex data',
        Data => {
            Key   => 'Teststring <tag> äß@ø " \\" \' \'\'',
            Value => [
                {
                    Subkey  => 'Value',
                    Subkey2 => undef,
                },
                1234,
                0,
                undef,
                'Teststring <tag> äß@ø " \\" \' \'\'',
            ],
        },
        SuccessDecode => 1,
    },
    {
        Name          => 'Special YAML chars',
        Data          => ' a " a " a \'\' a \'\' a',
        SuccessDecode => 1,
    },
    {
        Name          => 'UTF8 string',
        Data          => 'kéy',
        SuccessDecode => 1,
    },
    {
        Name          => 'UTF8 string, loader',
        Data          => 'kéy',
        YAMLString    => '--- kéy' . "\n",
        SuccessDecode => 1,
    },
    {
        Name          => 'UTF8 string without UTF8-Flag',
        Data          => 'k\x{e9}y',
        SuccessDecode => 1,
    },
    {
        Name          => 'UTF8 string without UTF8-Flag, loader',
        Data          => 'k\x{e9}y',
        YAMLString    => '--- k\x{e9}y' . "\n",
        SuccessDecode => 1,
    },
    {
        Name          => 'Very long string',      # see https://bugzilla.redhat.com/show_bug.cgi?id=192400
        Data          => ' äø<>"\'' x 40_000,
        SkipEngine    => 'YAML',                  # This test does not run with plain YAML, see the bug above
        SuccessDecode => 1,
    },
    {
        Name => 'Wrong newline',
        Data => {
            DefaultValue   => '',
            PossibleValues => undef,
        },
        YAMLString    => "---\rDefaultValue: ''\rPossibleValues: ~\r",
        SuccessDecode => 1,
    },
    {
        Name => 'Windows newline',
        Data => {
            DefaultValue   => '',
            PossibleValues => undef,
        },
        YAMLString    => "---\r\nDefaultValue: ''\r\nPossibleValues: ~\r\n",
        SuccessDecode => 1,
    },
    {
        Name => 'Unix newline',
        Data => {
            DefaultValue   => '',
            PossibleValues => undef,
        },
        YAMLString    => "---\nDefaultValue: ''\nPossibleValues: ~\n",
        SuccessDecode => 1,
    },
    {
        Name          => 'Invalid YAML string',
        Data          => '1',
        YAMLString    => "-\nDefaultValue: ''\nPossibleValues: ~\n",
        SuccessDecode => 0,
    },

 # Test case to reproduce a bug with YAML that is generated by the pure-perl YAML module.
 # See also http://blogs.perl.org/users/brian_d_foy/2010/06/block-sequence-entries-are-not-allowed-in-this-context.html.
    {
        Name => 'Missing quotes',
        Data => {
            PossibleValues => '-',
        },
        YAMLString    => "---\nPossibleValues: -\n",
        SuccessDecode => 1,
    },

    # This is how the previous example should look like
    {
        Name => 'Missing quotes (fixed)',
        Data => {
            PossibleValues => '-',
        },
        YAMLString    => "---\nPossibleValues: '-'\n",
        SuccessDecode => 1,
    },

    {
        Name          => 'Simple String 0',
        Data          => '0',
        SuccessDecode => 1,
    },
    {
        Name          => 'Number 0',
        Data          => 0,
        SuccessDecode => 1,
    },
    {
        Name          => 'Simple String 1',
        Data          => '1',
        SuccessDecode => 1,
    },
    {
        Name          => 'Number 1',
        Data          => 1,
        SuccessDecode => 1,
    },
    {
        Name          => 'Simple String 01',
        Data          => '01',
        SuccessDecode => 1,
    },
    {
        Name          => 'Number 01',
        Data          => 01,            ## no critic
        SuccessDecode => 1,
    },
    {
        Name          => 'Simple Empty String',
        Data          => '',
        SuccessDecode => 1,
    },
    {
        Name => 'Complex Structure with 0',
        Data => {
            Value1 => '0',
            Value2 => 0,
        },
        YAMLString    => "---\nValue1: 0\nValue2: 0\n",
        SuccessDecode => 1,
    },
);

ENGINE:
for my $Engine (qw(YAML::XS YAML)) {

    # locally override the internal engine of YAML::Any to force testing
    local @YAML::Any::_TEST_ORDER = ($Engine);    ## no critic

    TEST:
    for my $Test (@Tests) {

        next TEST if defined $Test->{SkipEngine} && $Engine eq $Test->{SkipEngine};

        my $YAMLString = $Test->{YAMLString} || $YAMLObject->Dump( Data => $Test->{Data} );
        my $YAMLData   = $YAMLObject->Load( Data => $YAMLString );

        if ( $Test->{SuccessDecode} ) {
            $Self->IsDeeply(
                $YAMLData,
                $Test->{Data},
                "Engine $Engine - $Test->{Name}",
            );
        }
        else {
            $Self->False(
                $YAMLData,
                "Engine $Engine - $Test->{Name}",
            );
        }
    }
}

1;
