let fold_lefti f default list =
  list
  |> Stdlib.List.fold_left (fun (i, acc) x -> succ i, f i acc x) (0, default)
  |> snd
;;
