package main

import "fmt"
import "bufio"
import "os"
import "strings"

func main() {
    reader := bufio.NewReader(os.ReadFile("/tmp/my_tmp_file"))
    text, _ := reader.ReadString('\n')
    text = strings.Trim(text, "\n")
    fmt.Println("Hello " + text + ", I'm golang")
}
