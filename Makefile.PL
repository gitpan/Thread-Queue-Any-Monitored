require 5.008;

# do we have threads?
my $module;
BEGIN {
    $module = "Thread::Queue::Any::Monitored";

    require Config;
    Config->import;

    if ( !$Config{useithreads} ) {
        print "$module requires a version of perl that has threads enabled.\n";
        exit 0;
    }
}

# set up stuff
use ExtUtils::MakeMaker;

# set version and dependency info
eval "use Devel::Required";

# set up
WriteMakefile (
 NAME		=> $module,
 AUTHOR		=> 'Elizabeth Mattijsen (liz@dijkmat.nl)',
 ABSTRACT	=> 'monitor a queue for any specific content',
 VERSION_FROM	=> 'lib/Thread/Queue/Any/Monitored.pm',
 PREREQ_PM	=> {
                    'Thread::Queue::Any' => '0.06',
                    'Thread::Queue::Monitored' => '0.07',
                   },
);
