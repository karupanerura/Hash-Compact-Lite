# NAME

Hash::Compact::Lite - It's new $module

# SYNOPSIS

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

# DESCRIPTION

Hash::Compact::Lite is ...

# LICENSE

Copyright (C) karupanerura.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

karupanerura <karupa@cpan.org>
