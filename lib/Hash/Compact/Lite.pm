package Hash::Compact::Lite;
use 5.008005;
use strict;
use warnings;

our $VERSION = "0.01";

use POSIX qw/:math_h/;
use Exporter 'import';
our @EXPORT = qw/hash_compact hash_uncompact/;

sub hash_compact {
    my ($orig, $dict) = @_;

    my $compact = defined($dict) ?
        _hash_compact($orig, $dict = +{ %$dict }, sub { $_[0] }):
        _hash_compact($orig, $dict = +{},         _gen_keygen());
    return +{
        data => $compact,
        dict => $dict,
    };
}

sub hash_uncompact {
    my $compressed = shift;
    return _hash_uncompact($compressed->{data}, +{ reverse %{$compressed->{dict}} });
}

sub _hash_uncompact {
    my ($compact, $dict) = @_;

    my $uncompact_value; $uncompact_value = sub {
        my $value = shift;
        return (ref $value && ref $value eq 'HASH')  ? _hash_uncompact($value, $dict) :
               (ref $value && ref $value eq 'ARRAY') ? [map { $uncompact_value->($_) } @$value]:
                                                       $value
    };

    my %orig;
    for my $key (keys %$compact) {
        my $orig_key = exists $dict->{$key} ? $dict->{$key} : $key;
        $orig{$orig_key} = $uncompact_value->( $compact->{$key} );
    }

    undef $uncompact_value;
    return \%orig;
}

my @key_chars           = map { chr } 33 .. 126;
my $key_chars_count     = scalar @key_chars;
my $key_chars_count_log = log($key_chars_count);
sub _gen_keygen {
    my $cnt = 0;
    return sub {
        my @text;

        $cnt++;
        for my $i (1 .. ceil(log($cnt + 1) / $key_chars_count_log) ) {
            push @text => $key_chars[
                floor(($cnt % ($key_chars_count ** $i)) / ($key_chars_count ** ($i - 1)))
            ];
        }

        return join '', reverse @text;
    };
}

sub _hash_compact {
    my ($orig, $dict, $keygen) = @_;

    my $compact_value; $compact_value = sub {
        my $value = shift;
        return (ref $value && ref $value eq 'HASH')  ? _hash_compact($value, $dict, $keygen) :
               (ref $value && ref $value eq 'ARRAY') ? [map { $compact_value->($_) } @$value]:
                                                       $value;
    };

    my %compact;
    for my $orig_key (keys %$orig) {
        my $key = exists $dict->{$orig_key} ? $dict->{$orig_key} : do {
            my $compact_key = $keygen->($orig_key);
            ($orig_key ne $compact_key) ? $dict->{$orig_key} = $compact_key : $compact_key;
        };
        $compact{$key} = $compact_value->( $orig->{$orig_key} );
    }

    undef $compact_value;
    return \%compact;
}

1;
__END__

=encoding utf-8

=head1 NAME

Hash::Compact::Lite - It's new $module

=head1 SYNOPSIS

    use Data::Dumper;
    use JSON qw/encode_json decode_json/;
    use Hash::Compact::Lite qw/hash_compact hash_uncompact/;

    my $data = +{
        entries => [
            map {
                +{
                    id   => $_,
                    name => "name_$_",
                    word => $_,
                },
            } 1 .. 1000
        ],
    };

    my $json = encode_json(hash_compact($data)); ## compact json!!

    print(Dumper(hash_uncompact(decode_json($json))));

=head1 DESCRIPTION

Hash::Compact::Lite is ...

=head1 LICENSE

Copyright (C) karupanerura.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

karupanerura E<lt>karupa@cpan.orgE<gt>

=cut

