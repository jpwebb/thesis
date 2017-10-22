function my_error(msg)

my_err.message = msg;
my_err.identifier = '';
my_err.stack.file = '';
my_err.stack.name = 'Calibration Tool';
my_err.stack.line = 1;

error(my_err);

end