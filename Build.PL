use Modern::Perl;
use Module::Build;

my $build = Module::Build->new(

    module_name => 'Tamper',
    dist_author => ['Olli-Antti Kivilahti <olli-antti.kivilahti@hypernova.fi>'],
    dist_abstract => 'Tamper detection daemon',

    build_requires => {
        'Modern::Perl' => '1',
    },

    requires => {
        'Modern::Perl'             => '> 0.01',
        'Time::HiRes'              => '> 0.01',
        'HiPi'                     => '> 0.01',
        'Config::Simple'           => '> 0.01',
        'JSON::XS'                 => '> 0.01',
        'Proc::PID::File'          => '> 0.01',
        'Try::Catch'               => '> 0.01',
    },

);

$build->create_build_script;
