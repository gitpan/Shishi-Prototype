# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

use Test;
BEGIN { plan tests => 6 }
END {print "not ok 1\n" unless $loaded;}
use Shishi qw(ACTION_SHIFT);
$loaded = 1;
ok(1);

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

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
$parser->parse_text("ab");
ok(!$parser->execute);

$parser->parse_text("abc");
ok($parser->execute);

$parser->parse_text("babdabc");
ok(!$parser->execute());

$parser->start_node->add_decision(
 new Shishi::Decision(type => 'skip', next_node => $parser->start_node,
 action => 4)
);
$parser->parse_text("babdabc");
ok($parser->execute());

ok(ACTION_SHIFT);
