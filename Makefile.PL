require 5.008;
use threads (); # just to force breakage if threads are not available
use ExtUtils::MakeMaker;

WriteMakefile (
 NAME		=> "Thread::Queue::Any::Monitored",
 ($[ >= 5.005) ?
 (AUTHOR	=> 'Elizabeth Mattijsen (liz@dijkmat.nl)',
  ABSTRACT	=> 'monitor a queue for any specific content') : (),
 VERSION_FROM	=> 'lib/Thread/Queue/Any/Monitored.pm',
 PREREQ_PM	=> {
                    'Thread::Queue::Any' => 0,
                    'Thread::Queue::Monitored' => 0,
                   },
);
