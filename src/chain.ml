let chain_to_machine = Unix.openfile "chain_to_machine" [Unix.O_WRONLY] 0o666
let () = print_endline "Opened chain_to_machine"
let machine_to_chain = Unix.openfile "machine_to_chain" [Unix.O_RDONLY] 0o666
let () = print_endline "Opened machine_to_chain"

let rec run n =
  let b = Bytes.create 8 in
  let b_len = Bytes.length b in
  Bytes.set_int64_ne b 0 n;
  let _write_result = Unix.write chain_to_machine b 0 b_len in
  Format.printf "Wrote int %Ld to machine\n%!" n;
  let _read_result = Unix.read machine_to_chain b 0 b_len in
  Format.printf "Read %d bytes from machine\n" _read_result;
  let n = Bytes.get_int64_ne b 0 in
  Format.printf "Received int %Ld from machine\n%!" n;
  Unix.sleep 1;
  run n
let ()  = run 0L
