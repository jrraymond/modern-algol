

let rec intercalate sep xs =
  match xs with
  | [] -> ""
  | [x] -> x
  | x::xs' -> x ^ sep ^ intercalate sep xs';;


let rec drop_while p xs =
  match xs with
  | x::xs' when p x -> drop_while p xs'
  | _ -> xs;;


let list_of_queue (q : 'a Queue.t) : 'a list =
  Queue.fold (fun xs x -> x::xs) [] q |> List.rev;;
