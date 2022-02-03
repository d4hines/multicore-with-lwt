package main

import (
	"encoding/binary"
	"fmt"
	"log"
	"os"
	"time"
)

func check(e error) {
	if e != nil {
		panic(e)
	}
}

func print_bytes(bs []byte) {
	for _, n := range bs {
		fmt.Printf("% 08b", n) // prints 00000000 11111101
	}
	fmt.Printf("\n")
}

func main() {
	chain_to_machine, err := os.OpenFile("chain_to_machine", os.O_RDONLY, 0666)
	if err != nil {
		log.Fatalf("Could not open the file: %s", err)
	}
	machine_to_chain, err := os.OpenFile("machine_to_chain", os.O_WRONLY, 0666)
	if err != nil {
		log.Fatalf("Could not open the file: %s", err)
	}

	b := make([]byte, 4)
	for {
		read, _ := chain_to_machine.Read(b)
		fmt.Printf("read %d bytes\n", read)

		print_bytes(b)
		// check(err)
		n := binary.LittleEndian.Uint16(b)
		fmt.Printf("Received number: %d\n", n)
		n = n + 1
		fmt.Printf("Incremented number: %d\n", n)
		binary.LittleEndian.PutUint16(b, n)
		machine_to_chain.Write(b)
		print_bytes(b)
		x := binary.LittleEndian.Uint16(b)
		fmt.Printf("Converted number: %d\n", x)
		time.Sleep(1000)
	}
}
