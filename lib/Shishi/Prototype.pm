package Shishi::Prototype;
$Shishi::Debug = 0;
1;
package Shishi;
use strict;
use Shishi::Node;
use Shishi::Decision;
use Exporter;
@Shishi::ISA = qw( Exporter );
@Shishi::EXPORT_OK = qw( ACTION_FINISH ACTION_REDUCE ACTION_CODE
ACTION_SHIFT ACTION_CONTINUE ACTION_FAIL);

sub new {
    my $self = shift;
    my $o = bless {
        creator => shift,
        decisions => [],
        nodes => [],
        stack => [],
    };
    # We start with one node
    $o->add_node(new Shishi::Node ($o->{creator}));
    return $o;
}

sub add_node {
    my $self = shift;
    my $node = shift;
    $node->{parents}++;
    push @{$self->{nodes}}, $node;
    return $self;
}

sub execute {
    my $self = shift;
    my $text = shift;
    $self->start_node->execute($self) > 0;
}

sub start_node { $_[0]->{nodes}->[0] }

sub parse_text { my $self = shift; @_ ? $self->{text} = shift : $self->{text};  } 

sub dump {
    my $parser = shift;
    print "Parser ".$parser->{creator}." dump\n";
    my %name2num;
    my @nodes = @{$parser->{nodes}};
    print ((scalar @nodes), " nodes\n\n");
    $name2num{$nodes[$_]}=$_ for 0..$#nodes;
    for (0..$#nodes) {
        my $n = $nodes[$_];
        print "$_:\n";
        for ($n->decisions) {
            print "\tMatch ".$_->{type}.":";
            print " ".$_->{target} if exists $_->{target};
            print " -> ";
            print "($_->{hint}) " if exists $_->{hint};
            if ($_->{action} == ACTION_FINISH) {
                print "DONE\n";
            } elsif ($_->{action} == ACTION_FAIL) {
                print "FAIL\n";
            } elsif ($_->{action} == ACTION_CONTINUE) {
                if (defined $_->{next_node}) {
                    print exists $name2num{$_->{next_node}} ?
                        $name2num{$_->{next_node}}
                        :
                        "UNKNOWN NODE ($_->{next_node})\n";
                } else { print "INCOMPLETE" }
                print "\n";
            } elsif ($_->{action} == ACTION_SHIFT) {
                print "SHIFT (something)\n";
            } elsif ($_->{action} == ACTION_REDUCE) {
                print "REDUCE\n";
            } elsif ($_->{action} == ACTION_CODE) {
                print "CODE (".$_->{code}.")\n";
            } else {
                print "UNKNOWN ACTION\n";
            }
        }
    }
}

# Create a parser for 'a b c'

1;

=head1 NAME

Shishi::Prototype - Internal use prototype for the Shishi regex/parser

=head1 SYNOPSIS

    my $parser = new Shishi ("test parser");
    $parser->start_node->add_decision(
     new Shishi::Decision(target => 'a', type => 'char', action => 4,
                              next_node => Shishi::Node->new->add_decision(
        new Shishi::Decision(target => 'b', type => 'char', action => 4,
                              next_node => Shishi::Node->new->add_decision(
            new Shishi::Decision(target => 'c', type => 'char', action => 0)
                                ))
                            ))
    );
    $parser->start_node->add_decision(
     new Shishi::Decision(type => 'skip', next_node => $parser->start_node,
     action => 4)
    );
    $parser->parse_text("babdabc");
    if ($parser->execute()) {
        print "Successfully matched\n"
    } else {
        print "Match failed\n";
    }

=head1 DESCRIPTION

This is a prototype only. The real library (C<Shishi>) will come once
this prototype is finalised. The interface will remain the same.

As this is only a prototype, don't try doing anything with it yet.
However, feel free to use Shishi applications such as
C<Shishi::Perl6Regex>.

When C<Shishi> itself is released, you can uninstall this module and
install C<Shishi> and everything ought to work as normal. (Except
perhaps somewhat faster.) However, since we're still firming up the
interface with this prototype, it's best not to depend on it; hence, the
interface is not currently documented.

=head1 AUTHOR

Simon Cozens, C<simon@netthink.co.uk>

=cut
