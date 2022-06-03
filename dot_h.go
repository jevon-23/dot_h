package main

import (
    "fmt"
    "os"
    "strings"
)

/* 
Takes in 2 strings, both of which are the a list of functions seperated
by a newline

Prints out all of the values in CONTENTS that is not in IGNORE
  aka: prints out all of the functions that we do not want to ignore
*/
func main() {

    /* No need to test against each other */
    if len(os.Args) < 3 {
        return;
    }

    var ignore, contents string;

    ignore = os.Args[1];   /* Functions we want to ignore */
    contents = os.Args[2]; /* Functions we are trying to add to .h */

    /* Split functions we want to add to .h by newline */
    splitContents := strings.Split(contents, "\n");

    /* Check to see if any of the new functions are inside of ignore */
    for _, fn := range splitContents {
        if !strings.Contains(ignore, fn) {
            fmt.Println(fn);
        }
    }
}
