package Thread::Queue::Any::Monitored;

# Make sure we inherit from threads::shared::queue
# Make sure we have version info for this module
# Make sure we do everything by the book from now on

@ISA = qw(Thread::Queue::Any);
$VERSION = '0.01';
use strict;

# Make sure we have super duper queues
# Make sure we have monitored queues

use Thread::Queue::Any ();
use Thread::Queue::Monitored ();

# Make sure we can do naughty things
# For all the subroutines that are identical to normal queues are monitored
#  Make sure they are the same

{
 no strict 'refs';
 foreach (qw(new dequeue dequeue_nb)) {
     *$_ = \&{"Thread::Queue::Monitored::$_"};
 }
}

# Satisfy -require-

1;

#---------------------------------------------------------------------------

# Internal subroutines

#---------------------------------------------------------------------------
#  IN: 1 queue object to monitor
#      2 flag: to keep thread attached
#      3 code reference of monitoring routine
#      4 exit value

sub _monitor {

# Obtain the queue and the code reference to work with
# Make sure this thread disappears outside if we don't want to keep it

    my ($queue,$keep,$code,$exit) = @_;
    threads->self->detach unless $keep;

# Initialize the list with values to process
# While we're processing
#  Wait until we can get a lock on the queue
#  Wait until something happens on the queu
#  Obtain all values from the queue
#  Reset the queue

    my @value;
    while( 1 ) {
        {
         lock( @{$queue} );
         threads::shared::cond_wait @{$queue} until @{$queue};
         @value = @{$queue};
         @{$queue} = ();
        }

#  For all of the values just obtained
#   Obtain the actual values that are frozen in the value
#   Return now if so indicated
#   Call the monitoring routine with all the values
	
        foreach (@value) {
	    my @set = @{Storable::thaw( $_ )};
            return if $set[0] eq $exit;
            $code->( @set );
        }
    }
} #_monitor

#---------------------------------------------------------------------------

__END__

=head1 NAME

Thread::Queue::Any::Monitored - monitor a queue for any content

=head1 SYNOPSIS

    use Thread::Queue::Any::Monitored;
    my $q = Thread::Queue::Any::Monitored->new( \&monitor );
    my ($q,$t) = Thread::Queue::Any::Monitored->new( \&monitor,'exit' );
    $q->enqueue( "foo" );
    $q->enqueue( undef ); # exit value by default

    $t->join; # wait for monitor thread to end

    sub monitor {
      warn $_[0] if $_[0] =~ m/something wrong/;
    }

=head1 DESCRIPTION

                    *** A note of CAUTION ***

 This module only functions on Perl versions 5.8.0-RC3 and later.
 And then only when threads are enabled with -Dusethreads.  It is
 of no use with any version of Perl before 5.8.0-RC3 or without
 threads enabled.

                    *************************

A queue, as implemented by C<Thread::Queue::Any::Monitored> is a thread-safe 
data structure that inherits from C<Thread::Queue::Any>.  But unlike the
standard C<Thread::Queue::Any>, it starts a single thread that monitors the
contents of the queue by taking new sets of values off the queue as they
become available.

It can be used for simply logging actions that are placed on the queue. Or
only output warnings if a certain sets of values is encountered.  Or whatever.

The action performed in the thread, is determined by a name or reference
to a subroutine.  This subroutine is called for every set of values obtained
from the queue.

Any number of threads can safely add sets of values to the end of the list.

=head1 CLASS METHODS

=head2 new

 $queue = Thread::Queue::Any::Monitored->new( \&monitor );
 $queue = Thread::Queue::Any::Monitored->new( \&monitor,'exit' );
 ($queue,$thread) = Thread::Queue::Any::Monitored->new( \&monitor );
 ($queue,$thread) = Thread::Queue::Any::Monitored->new( \&monitor,'exit' );

The C<new> function creates a new empty queue.  It returns the instantiated
Thread::Queue::Any::Monitored object in scalar context: in that case, the
monitoring thread will be detached and will continue until the exit value is
passed on to the queue.  In list context, the thread object is also returned,
which can be used to wait for the thread to be really finished using the
C<join()> method.

The first input parameter is a name or reference to a subroutine that will
be called to check on each value that is added to the queue.  It B<must> be
specified.  The subroutine is to expect all parameters that were L<enqueued>
at a time: the values to check.  It is free to do with that values what it
wants.

The second (optional) input parameter is the value that will signal that the
monitoring of the thread should seize.  If it is not specified, the C<undef>
value is assumed.  To end monitoring the thread, L<enqueue> the same value.

=head1 OBJECT METHODS

=head2 enqueue

 $queue->enqueue( $scalar,[],{} );
 $queue->enqueue( 'exit' ); # stop monitoring

The C<enqueue> method adds all specified parameters as a set on to the end
of the queue.  The queue will grow as needed to accommodate the list.  If the
"exit" value is passed, then the monitoring thread will shut itself down.

=head1 CAVEATS

You cannot remove any values from the queue, as that is done by the monitoring
thread.  Therefore, the methods "dequeue" and "dequeue_nb" are disabled on
this object.

Passing unshared values between threads is accomplished by serializing the
specified values using C<Storable> when enqueuing and de-serializing the queued
value on dequeuing.  This allows for great flexibility at the expense of more
CPU usage.  It also limits what can be passed, as e.g. code references can
B<not> be serialized and therefore not be passed.

=head1 AUTHOR

Elizabeth Mattijsen, <liz@dijkmat.nl>.

Please report bugs to <perlbugs@dijkmat.nl>.

=head1 COPYRIGHT

Copyright (c) 2002 Elizabeth Mattijsen <liz@dijkmat.nl>. All rights
reserved.  This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<threads>, L<threads::shared>, L<Thread::Queue::Any>, L<Storable>.

=cut
