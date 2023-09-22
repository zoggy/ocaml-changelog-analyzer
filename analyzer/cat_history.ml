open Common


let count_category_by_release cat (x:Changelog.Def.t) =
  let by_release (history, previous) release x =
    let set =
      fold_entry_by_section ~f:(fun set _ _ x -> Cat.add cat set x)
        Name_set.empty release x
    in
    let all = Name_set.union previous set in
    let diff = Name_set.diff set previous in
    (release, diff, Name_set.cardinal set, Name_set.cardinal diff) :: history , all
  in
  let history, _ = fold_field ~f:by_release ([], Name_set.empty) (List.rev x) in
 List.rev history

let () =
  let filename = Sys.argv.(1) and cat = Sys.argv.(2) in
  let changelog = changelog_from_file filename in
  let history = count_category_by_release cat changelog in
  let pp_author_info ppf (r,diff,any,news) =
    Fmt.pf ppf "%S %d %d @[<h>{%a}@]"
      r any news Fmt.(list ~sep:Fmt.comma Changelog.Def.Pp.name) (Name_set.elements diff)
  in
    Fmt.pr "@[<v>#%s History@,# Contributors\tNew contributors\tNames@,%a@]@." cat
    (Fmt.list pp_author_info) history
