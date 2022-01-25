
type line =
    | Txt of string
    | Codeblock of string
    | EndCodeBlock

let get_lang_name ( file : string )= begin 
    let split =  String.split_on_char '.' file  in 
    List.hd @@ List.tl split
end

let tokenize ( s : string  )= List.map 
(fun ln -> begin
    if String.starts_with ~prefix:("```") (String.trim ln ) then
        let trimmed_ln = String.trim ln in 
        let rem=String.sub trimmed_ln 3 (( String.length trimmed_ln ) - 3) in
        match rem with
            | "" -> EndCodeBlock
            | ext -> Codeblock ext
    else Txt ln
end
)  
( String.split_on_char '\n' s)
;;


(* a *)
type code_block = {
    lang: string ;
    block: string list;
    complete: bool;
}

let get_code_blocks ( tokens : line list )  = begin
    List.fold_left ( fun acc l -> begin
        match l with
         | Codeblock language -> begin
             let block = {
                 lang= language;
                 block= [];
                 complete= false;
            } in ( block::acc )
         end
         | EndCodeBlock -> begin
             match acc with
             | [] -> failwith "Codeblock should have a langauge type written after it"
             | x::xs -> let y = {x with complete = true; block = (List.rev x.block) } in ( y::xs )
         end
         | Txt s -> match acc with
            | [] -> []
            | x::xs -> begin match x.complete with
                | true -> acc
                | false -> (({x with block = s::x.block })::xs)
            end
         end
    )  [] tokens
end

let read_to_string filename =
    let ch = open_in filename in
    let s = really_input_string ch (in_channel_length ch) in
    close_in ch;
    s

let get_all_code_blocks_of_lang_from_md filename =
    let filetype = get_lang_name filename in
    let filecontent = read_to_string filename in
    filecontent |> tokenize |> get_code_blocks |> (List.filter (fun (cb: code_block) -> cb.lang = filetype) )
                |> List.rev |> (List.map (fun (cb: code_block ) -> cb.block)) |> List.flatten |> (String.concat "\n");;
    


let usage_msg = "-i <in_file> -o <out_file>"
let input_file = ref ""
let output_file = ref ""

let anon_fun _ =  ()

let speclist =
[("-i", Arg.Set_string input_file, "Set input file name");
("-o", Arg.Set_string output_file, "Set output file name")]

let () =
    Arg.parse speclist anon_fun usage_msg;;

let () = if !input_file = "" then failwith "Input file name required"

let () = let out = get_all_code_blocks_of_lang_from_md !input_file in
    match !output_file with
    | "" -> print_endline out
    | filename -> begin 
        let f = open_out filename in
        Printf.fprintf f "%s\n" out 
    end
