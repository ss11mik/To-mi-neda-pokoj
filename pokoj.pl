% project: FLP 2023 To mi nedá pokoj
% author: xmikul69
% date: 04/2023
% file: pokoj.pl



% --------- Definition of game board ---------


% adjacency is symmetrical relation
adjacent_square(F1, F2, left) :- adjacent_horizontal_square(F2, F1).
adjacent_square(F1, F2, up) :- adjacent_vertical_square(F2, F1).
adjacent_square(F1, F2, right) :- adjacent_horizontal_square(F1, F2).
adjacent_square(F1, F2, down) :- adjacent_vertical_square(F1, F2).


% 1st row
adjacent_vertical_square(F1, F2) :-
    plus(F1, 4, F2),
    F1 >= 1, F1 =< 3.

% 7th row
adjacent_vertical_square(F1, F2) :-
    plus(F1, 4, F2),
    F1 >= 31, F1 =< 33.

% 2nd row
adjacent_vertical_square(F1, F2) :-
    plus(F1, 6, F2),
    (F1 >= 4, F1 =< 8).

% 6th row
adjacent_vertical_square(F1, F2) :-
    plus(F1, 6, F2),
    F1 >= 24, F1 =< 28.

% 3th, 4th and 5th row
adjacent_vertical_square(F1, F2) :-
    plus(F1, 7, F2),
    F1 >= 9, F1 =< 22.

% for horizontal adjacency, the offset is 1, except for leftmost squares
adjacent_horizontal_square(F1, F2) :-
    plus(F1, 1, F2),
    F1 \= 3,
    F1 \= 8,
    F1 \= 15,
    F1 \= 22,
    F1 \= 29,
    F1 \= 34.



% --------- Game logic ---------


% counts remaining pieces
remaining(Board, Remaining) :- sumlist(Board, Remaining).


% remove piece from board to given square
remove_piece([1|Board], 1, [0|Board]) :- !.
remove_piece([X|Board1], Square, [X|Board2]) :-
    !, Next_square is Square - 1,
    remove_piece(Board1, Next_square, Board2).

% add piece to board to given square
add_piece([0|Board], 1, [1|Board]) :- !.
add_piece([X|Board1], Square, [X|Board2]) :-
    !, Next_square is Square - 1,
    add_piece(Board1, Next_square, Board2).

% make a move in the game
% legality of the move is not checked here
move_piece(Board, From, Through, To, New_Board) :-
    !, remove_piece(Board, From, Board1),            % lift piece from original position,
    !, remove_piece(Board1, Through, Board2),        % remove the jumped-over one,
    !, add_piece(Board2, To, New_Board).             % land the piece behind.


% suggest a legal move in given position
% only gives information about the move, does not execute it
possible_move(Board, From, To, Direction, Through) :-
    nth1(From, Board, 1),
    adjacent_square(From, Through, Direction),
    nth1(Through, Board, 1),
    adjacent_square(Through, To, Direction),
    nth1(To, Board, 0).



% --------- Printing ---------


% prints a move
print_move(From, To) :-
    write(From),
    write('-'),
    write('>'),
    write(To),
    write('\n').


% prints the whole solution, consisting of states of boards and moves
print_boards([]).
print_boards([[Board, From, Through, To] | Tail]) :-
    print_move(From, To),
    print_board(Board, From, Through, To),
    write('\n'),
    print_boards(Tail).


start_highlight :-
    string_codes(S, "\033[31;1;4m"),
    write(S).

stop_highlight :-
    string_codes(S, "\033[0m"),
    write(S).

separator_for_index(1, Separator) :- string_codes(Separator, "    ").
separator_for_index(35, Separator) :- string_codes(Separator, "\n    ").
separator_for_index(9, '\n').
separator_for_index(16, '\n').
separator_for_index(23, '\n').
separator_for_index(4, Separator) :- string_codes(Separator, "\n  ").
separator_for_index(30, Separator) :- string_codes(Separator, "\n  ").
separator_for_index(_, Separator) :- string_codes(Separator, " ").

% prints a board
print_board(Board) :- print_board(Board, _, _, _).

% pints a board, with moved pieces highligted
print_board(Board, From, Through, To) :- print_board1(Board, 1, From, Through, To).

print_board1([], _, _, _, _) :- write('\n').
print_board1([X|Board], Index, From, Through, To) :-
    separator_for_index(Index, Separator),  % squares after line break
    ((                                      % highligt moved pieces
        (
            From == Index;
            Through == Index;
            To == Index
        ),
        write(Separator),
        start_highlight,
        write(X),
        stop_highlight
    );
    (
        write(Separator),
        write(X)
    )),
    Next_index is Index + 1,
    print_board1(Board, Next_index, From, Through, To).



% --------- Parsing input ---------


% loads the Board from stdin
load_board(Board) :- load_board1(Board, 0).

% end after encountering 37 ones and zeros
load_board1([], 37).

% if the char is 1 or 0, add it to the board
load_board1([Num | Board], N) :-
    peek_char(Elem),
    (Elem == '0'; Elem == '1'),
    get_char(Elem),
    atom_number(Elem, Num),
    Next is N + 1,
    load_board1(Board, Next).

% consume other characters
load_board1(Board, N) :-
     get_char(_),
     load_board1(Board, N).



% --------- Main logic ---------


% entry point
run(_) :-                   % swipl 6.6.1 for some reason requires at least one argument
    load_board(Board),
    !,                      % prevents from reading input when the position is unsolveable
    solve(Board).


solve(Board) :-
    assertz(unsolveable(0, [1])), %foo
    remaining(Board, Remaining),                            % count the pieces we start with,
    solve(Board, Remaining, Result),                        % try to solve the board
    print_boards(Result).                                   % and in case of success, print the solution.

% in case the above fails, inform user that the board has no solution.
solve(_) :-
    write("No solution found.\n"),
    fail.


% position with 1 piece is a winning position
solve(_, 1, []) :- !.

solve(Board, Remaining, Result) :-
    not(unsolveable(Remaining, Board)),                     % if this position has not been encountered before,
    possible_move(Board, From, To, _, Through),     % find a move
    move_piece(Board, From, Through, To, New_Board),        % execute it
    New_Remaining is Remaining - 1,
    solve(New_Board, New_Remaining, Next_Result),           % and try to solve the new position
    Result = [[Board, From, Through, To] | Next_Result].

% if the above predicate fails, save this position to DB of unsolveable positions
solve(Board, Remaining, _) :-
    asserta(unsolveable(Remaining, Board)),     % asserta is empirically faster than assertz in this case
    fail.
