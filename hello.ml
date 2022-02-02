let (let*) = Lwt.bind

let pmap = fun (command, args) input ->
  let send = fun stdin data ->
    Lwt.finalize
    (fun () -> Lwt_io.write stdin data)
    (fun () -> Lwt_io.close stdin) in

  let recv = fun stdout ->
    Lwt.finalize
      (fun () -> Lwt_io.read stdout)
      (fun () -> Lwt_io.close stdout) in

  let (stdin_r, stdin_w) = Unix.pipe () in
  let (stdout_r, stdout_w) = Unix.pipe () in

  let stdin = Lwt_io.of_unix_fd ~mode:Lwt_io.output stdin_w in
  let stdout = Lwt_io.of_unix_fd ~mode:Lwt_io.input stdout_r in

  let _pid =
    Unix.create_process command args stdin_r stdout_w Unix.stderr in
  
  let () = Unix.close stdin_r in
  let () = Unix.close stdout_w in

  let sender = send stdin input in
  let getter = recv stdout in

  Lwt.catch
    (fun () ->
      let* () = sender in
      getter
    )
    (fun exn -> match exn with
      | Lwt.Canceled as exn ->
        Lwt.cancel getter;
        Lwt.fail exn
      | exn -> Lwt.fail exn
    )

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
  let* y = pmap ("node", [| "node"; "./run_entrypoint.js" |]) json in
  print_endline y;
  server (x + 1)

let () = Lwt_main.run (server 0)
