require 5.008;
use threads (); # just to force breakage if threads are not available
use ExtUtils::MakeMaker;
eval "use Devel::Required";

WriteMakefile (
 NAME		=> "Thread::Queue::Any::Monitored",
 AUTHOR		=> 'Elizabeth Mattijsen (liz@dijkmat.nl)',
 ABSTRACT	=> 'monitor a queue for any specific content',
 VERSION_FROM	=> 'lib/Thread/Queue/Any/Monitored.pm',
 PREREQ_PM	=> {
                    'Thread::Queue::Any' => '0.06',
                    'Thread::Queue::Monitored' => '0.07',
                   },
);
