# dot_h
An interface for creating / updating .h files

Reads the given .c file and extracts all of the function defintions. Based on the **.dot_h.ignore** file as, the program
updates the .h file to contain the functions that have not been defined in the **.dot_h.ignore** file

To generate / update new **.dot_h.ignore** file <br>
``` ./dot_h.sh -i {function_name} {file_name}```

<br>
To generate / update new .h file <br>

``` ./dot_h.sh -u {file_name} ```

# Things I learned / Notes & Misc

1. Command line tools are amazing <br>
  1.1. Core functionality utilizes grep, sed, and diff <br>
2. Bash is amazing (but we already knew this) <br>
  2.1. Being in bash allows for a lot of very powerful command line tools, alongside an easy interface to execute scripts in higher level languages <br>
  2.2. Colors w/ echo! <br>
3. Using an ignore file can be very similar to setting up a configuration file. This is a simple example but being able to specify the functions
   that I do not want to be used is super important and creating an interface to interact with it indirectly is great <br>
4. Vim is probably the best editor to edit text on and I can't wait to get better <br>
5. This is a scrappy project and not meant for efficiency at all, not even sure how reliable. Really just wanted to make a quick yet effective script
   that can be of some usage to me even with minimal completion <br>
    On the other hand, I am not sure how likely it is for me to use this given the fact that a lot of the time through test-driven development as soon
    as I define a function, most of the time I define it in my .h file as well. <br>
6. TODO:<br>
  6.2. Allow for user to pass in path to desired .h file<br>
  6.4  Produce a way to remove a value from the .h & .ignore file<br>
  
  6.1. Allow for **-i** to take in more than one fn at a time to append to .ignore file<br> - Completed
  6.3. Also maybe allow for writing from .h => .c instead? <br> - Unnecessary
  6.5  Print .h & .ignore file<br> - Completed



