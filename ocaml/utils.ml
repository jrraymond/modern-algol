

let rec intercalate sep xs =
  match xs with
  | [] -> ""
  | [x] -> x
  | x::xs' -> x ^ sep ^ intercalate sep xs';;


(* equivalent to (takeWhile p xs, dropWhile p xs) *)
let split_while p =
  let rec go ls xs =
    match xs with
    | x::xs' when p x -> go (x::ls) xs'
    | _ -> List.rev ls, xs
  in go [];;
 
let rec drop_while p i xs =
  match i, xs with
  | 0, _ -> xs
  | _, x::xs' when p x -> drop_while p (i - 1) xs'
  | _ -> xs;;




let list_of_queue (q : 'a Queue.t) : 'a list =
  Queue.fold (fun xs x -> x::xs) [] q |> List.rev;;


let subset_of a b =
  try
    let () = Hashtbl.iter (fun k v ->
      if v = Hashtbl.find b k
      then ()
      else raise Not_found
    ) a
    in true
  with Not_found -> false;;

let omap f s =
  match s with
  | None -> None
  | Some x -> Some (f x);;


let rmap f r =
  match r with
  | Ok x -> Ok (f x)
  | Error e -> Error e;;


let from_opt f o =
  match o with
  | None -> f ()
  | Some x -> x;;


let accum_left f0 z0 xs0 =
  let rec go ys f z xs =
    match xs with
    | [] -> z, List.rev ys
    | x::xs' ->
        let z', y = f z x in
        go (y::ys) f z' xs'
  in go [] f0 z0 xs0;;
