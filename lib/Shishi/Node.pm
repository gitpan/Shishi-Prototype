package Shishi::Node;
use strict;

sub new {
    my $class = shift;
    bless {
        creator => shift,
        parents => 0, 
        decisions => [],
    }, $class;
}

sub execute { 
    my $self = shift;
    my $parser = shift;
    print "Executing node $self, parser is $parser\n" if $Shishi::Debug;
    for (@{$self->{decisions}}) {
        my $rc = $_->execute($parser);
        return -1 if $rc == -1;
        return 1 if $rc == 1;
    }
    return 0;
}

sub add_decision {
    my $self = shift;
    push @{$self->{decisions}}, shift;
    return $self;
}

sub decisions { @{$_[0]->{decisions}} }

1;
