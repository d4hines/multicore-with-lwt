let (let*) = Lwt.bind

let pool = ref (Obj.magic 0) 

let running = ref false

let do_parallel x =
  if !running then
    Lwt.return_unit
  else begin
    Format.printf "spawning slow computation %d\n%!" x;
    running := true;
    let* result = Lwt_domain.detach !pool (fun () -> Unix.sleep 5; x + 1) () in
    Format.printf "slow computation done %d\n%!" result;
    running := false;
    Lwt.return_unit
end

let initiated = ref false
let rec server x = 
  if !initiated then (
  Format.printf "tick %d\n%!" x;
  Lwt.async(fun () -> do_parallel x);
  let* _ = Lwt_unix.sleep(1.) in
  let* _ = Lwt_process.pmap ("", [| "echo"; "hello world" |]) "" in
  server (x + 1)
  )
else (
 pool := Lwt_domain.setup_pool 4;
initiated := true;
 server x
)
 

let () = Lwt_main.run (server 0)
