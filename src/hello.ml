
(* let go_to_ocaml = Unix.openfile  "./go_to_ocaml" [ Unix.O_RDONLY;  Unix.O_NONBLOCK  ] 0o600 *)
(* open Unix
let file_permissions = 0o666 

let my_temp_file = "/tmp/my_tmp_file"
let myfifo = Unix.openfile my_temp_file [ O_WRONLY; O_CREAT ] file_permissions
let () = print_endline "done" *)

open Unix
let file_permissions = 0o666 
let go_to_ocaml = "/tmp/go_to_ocaml"
let ocaml_to_go = "/tmp/ocaml_to_go"
let () = if not @@ Sys.file_exists go_to_ocaml then
     mkfifo go_to_ocaml file_permissions
let () = if not @@ Sys.file_exists ocaml_to_go then
    mkfifo ocaml_to_go file_permissions


let write fd data = 
let bytes_remaining = ref (Bytes.length data) in
  let pos = ref 0 in
  while !bytes_remaining > 0 do
    let bytes_written = Unix.write fd data !pos !bytes_remaining in
    bytes_remaining := !bytes_remaining - bytes_written;
    pos := !pos + bytes_written
  done

let read fd = 
  Unix.read

let send_to_go data = 
  let ocaml_to_go = Unix.openfile ocaml_to_go [ Unix.O_WRONLY ] file_permissions in
  write ocaml_to_go data 

let recv_from_go () =
  let go_to_ocaml = Unix.openfile go_to_ocaml [ Unix.O_RDONLY ] file_permissions in



let myfifo = Unix.openfile fifo_file [ Unix.O_WRONLY ] file_permissions
let () = print_endline "done"

(* let () = print_endline "Sending data to the go program..." *)

(* let () = 
  let pid = 
    Unix.create_process "./hello" [|"./hello"; "ocaml\n"|] ocaml_to_go Unix.stdout Unix.stderr in
  let (_pid, _process_status) = Unix.waitpid [] pid in
  () *)

(* 
let spawn = fun (command, args) input ->
  let (stdin_r, stdin_w) = Unix.pipe () in
  let (stdout_r, stdout_w) = Unix.pipe () in
  let pid = 
    Unix.create_process command args stdin_r stdout_w Unix.stderr in

let pool = Lwt_domain.setup_pool 4

let running = ref false

let do_parallel x =
  if !running then
    Lwt.return_unit
  else begin
    Format.printf "spawning slow computation %d\n%!" x;
    running := true;
    let* result = Lwt_domain.detach pool (fun () -> Unix.sleep 5; x + 1) () in
    Format.printf "slow computation done %d\n%!" result;
    running := false;
    Lwt.return_unit
end

let rec server x = 
  Format.printf "tick %d\n%!" x;
  (* Lwt.async(fun () -> do_parallel x); *)
  let* _ = Lwt_unix.sleep(1.) in
  let json = {|{"rpc_node":"http://localhost:20000","secret":"edsk3QoqBuvdamxouPhin7swCvkQNgq4jP5KZPbwWNnwdZpSpJiEbq","confirmation":1,"destination":"KT1HpM99QT7Va8J2GuHpm685nELDm2DwP38f","entrypoint":"update_root_hash","payload":{"block_height":2,"block_payload_hash":"7d52bc87e2eaaaf9588abe397efa072468de0447e74109d77f0930396fbb79ee","signatures":["edsigtxqFpi3Ab6yjUe3Y4Z5dyKBaHAEdmRTUCHkY6v2euFrAjZHGqhNXaSE53N9uSnuJ9Ce8Df3P5hYxGn5u9L58GkCCyRHmoo","edsigtbQ6ZjGQWMJdjN68cy7NU2zTxzWMizd6ccXKsw8HhZvP4zWBzFuTFvbinxUQosdvxqhfF7PdRoWc99E4nMjF8Jj96BzSVV",null],"handles_hash":"0e5751c026e543b2e8ab2eb06099daa1d1e5df47778f7787faab45cdf12fe3a8","state_hash":"96bb512796503866277559b3a38b1b0d000b6e6f9ea4d1f82ee9ea845d41965c","validators":["tz1g2osGmq5eVAAoErTiqeebYLXuN1PnaDz5","tz1h9A9xQMnECDWkbhJ1sjhW2XRihN5yb2qK","tz1NDjSGDpXppa7C36cxG9pgEvdQZc21PQ8M"],"current_validator_keys":["edpku3LUw5AU71BW74CwLY2unDoDoX11YgtvKJaefErko91L5H9vSj","edpkuHpPAejiRhxwtXRofoXtoCyLYZNTiGnQBnkU7PWg5CueSMt3MZ",null]}}|} in
  let* y = pmap ("esy", [| "esy"; "node"; "./run_entrypoint.js" |]) json in
  print_endline y;
  server (x + 1)

let () = Lwt_main.run (server 0) *)
