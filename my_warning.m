function my_warning(msg)

warning('OFF', 'BACKTRACE');
warning('OFF', 'VERBOSE');
warning(msg, '');
warning('ON', 'BACKTRACE');

end