package Shishi::Decision;
use Exporter;

use constant ACTION_FINISH   => 0;
use constant ACTION_REDUCE   => 1;
use constant ACTION_SHIFT    => 2;
use constant ACTION_CODE     => 3;
use constant ACTION_CONTINUE => 4;
use constant ACTION_FAIL     => 5;

@Shishi::Decision::ISA = qw( Exporter );
@Shishi::Decision::EXPORT = qw( ACTION_FINISH ACTION_REDUCE ACTION_CODE
ACTION_SHIFT ACTION_CONTINUE ACTION_FAIL);

sub new {
    my $class = shift;
    bless { @_ }, $class;
}

sub execute {
    my ($self, $parser) = (@_);
    my $text = $parser->parse_text();
    my $targ = $self->{target};
    my $type = $self->{type};
    print "Trying decision $type -> $targ on $text ($self)\n" 
        if $Shishi::Debug;
    if ($type eq "char" or $type eq "text") {
        goto success if $text =~ s/^$targ//;
    } elsif ($type eq "token") {
        my $tt = chr($self->{token});
        goto success if $text =~ s/^$tt//;
    } elsif ($type eq "any" or $type eq "skip") {
        goto success if $text =~ s/^.//;
    } elsif ($type eq "code") { 
        print "Performing code\n"
            if $Shishi::Debug;
        my $result = $self->{code}->($parser, \$text);
        print "Result from code is $result\n"
            if $Shishi::Debug;
        goto success if $result;
    } elsif ($type eq "true") {
        goto success;
    } else {
        die "Unknown decision type $type";
    }
    return 0;

    success:
    $parser->parse_text($text);
    return $self->action($parser);
}

sub action {
    my $self = shift;
    my $parser = shift;
    die "Bad action $self->{action}\n" if not defined $self->{action};
    print "Performing action $self->{action}\n"
            if $Shishi::Debug;
    if ($self->{action} == ACTION_CONTINUE) {
        return $self->{next_node}->execute($parser);
    } elsif ($self->{action} == ACTION_FINISH) {
        return 1;
    } elsif ($self->{action} == ACTION_FAIL) {
        return -1;
    }
}

sub next_node {
    my $self = shift;
    if (@_) { $self->{next_node} = shift } else { $self->{next_node} }
}

1;

