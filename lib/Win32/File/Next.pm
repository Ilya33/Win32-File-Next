package Win32::File::Next;

use strict;
use warnings;

use Win32::LongPath;

$Win32::File::Next::VERSION = "0.001_000";



sub everything {
    #croak if $_[0] eq __PACKAGE__
    #shift options

    #for(@_) {
        my $dir_obj = Win32::LongPath->new();
        $dir_obj->opendirL(shift);
        my @a = $dir_obj->readdirL();
        $dir_obj->closedirL($_);
        return @a;
    #}
}



1;



__END__

=encoding utf-8

=head1 NAME

Win32::File::Next - It's new $module

=head1 SYNOPSIS

    use Win32::File::Next;

=head1 DESCRIPTION

Win32::File::Next is ...

=head1 LICENSE

Copyright (C) Ilya Pavlov.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Ilya Pavlov E<lt>ilux@cpan.orgE<gt>

=cut