package Shishi::Node;
use Shishi::Decision;
use strict;

sub new {
    my $class = shift;
    bless {
        creator => shift,
        parents => 0, 
        decisions => [],
    }, $class;
}

my %match = (
    char => sub { my ($d, $tr) = @_; my $targ = $d->{target}; $$tr =~ s/^$targ//; },
    text => sub { my ($d, $tr) = @_; my $targ = $d->{target}; $$tr =~ s/^$targ//; },
    token => sub { my ($d, $tr) = @_; my $tk = chr $d->{token}; $$tr =~ s/^$tk//; },
    any=> sub { my ($d, $tr) = @_; $$tr =~ s/.//; },
    skip=> sub { my ($d, $tr) = @_; $$tr =~ s/.//; },
    true => sub {1},
    code => sub { my ($d, $tr, $parser) = @_;
        print "Performing code\n" if $Shishi::Debug;
        $d->{code}->($parser, $tr);
    },
);

sub execute { 
    my $self = shift;
    my $parser = shift;
    my $match_object = shift;
    print "Executing node $self, parser is $parser, mo is $match_object\n" if $Shishi::Debug;
    for my $d ($self->decisions) {
        my $text = $match_object->parse_text();
        my $targ = $d->{target};
        my $type = $d->{type};
        my $action = $d->{action};
        print "Trying decision $type -> $targ on $text ($d)\n" 
            if $Shishi::Debug;
        die "Unknown match type $type" unless exists $match{$type};
        next unless $match{$type}->($d, \$text, $parser); # Match
        $match_object->parse_text($text);
        my $rc;
        if ($action == ACTION_CONTINUE) {
           $rc = $d->{next_node}->execute($parser, $match_object);
           return $rc unless $rc == 0;
        } elsif ($self->{action} == ACTION_FINISH) {
           return 1;
        } elsif ($self->{action} == ACTION_FAIL) {
           return -1;
        }
    }
    return 0;
}

sub add_decision {
    my $self = shift; push @{$self->{decisions}}, shift; return $self;
}

sub decisions { @{$_[0]->{decisions}} }

1;
