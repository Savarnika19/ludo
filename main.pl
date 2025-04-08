% --- LUDO GAME FOR 8 PLAYERS ---

% --- Configuration ---
num_players(8).
board_size(52).
tokens_per_player(4).

% --- Dynamic State ---
% token(PlayerID, TokenID, Position)
:- dynamic token/3.

% --- Game Initialization ---
initialize_tokens :-
    retractall(token(_, _, _)),
    num_players(TotalPlayers),
    tokens_per_player(TokensEach),
    forall(between(1, TotalPlayers, PlayerID),
           forall(between(1, TokensEach, TokenID),
                  assertz(token(PlayerID, TokenID, -1)))).

% --- Dice Roll ---
roll_dice(Dice) :-
    random_between(1, 6, Dice).

% --- Token Movement ---
move_token_on_board(PlayerID, TokenID, Dice) :-
    token(PlayerID, TokenID, CurrentPos),
    NewPos is (CurrentPos + Dice) mod 52,
    retract(token(PlayerID, TokenID, CurrentPos)),
    assertz(token(PlayerID, TokenID, NewPos)),
    format('Player ~w moved token ~w from ~w to ~w.~n', [PlayerID, TokenID, CurrentPos, NewPos]).

enter_token_to_board(PlayerID, TokenID) :-
    retract(token(PlayerID, TokenID, -1)),
    assertz(token(PlayerID, TokenID, 0)),
    format('Player ~w brings token ~w onto the board at position 0.~n', [PlayerID, TokenID]).

% --- Token Selection ---
select_movable_token(PlayerID, Dice, TokenID) :-
    token(PlayerID, TokenID, Position),
    (Position \= -1 ; Dice = 6),  % Can move if already on board or Dice is 6
    !.

% --- Player Turn ---
player_turn(PlayerID) :-
    roll_dice(Dice),
    format('Player ~w rolled a ~w.~n', [PlayerID, Dice]),
    ( select_movable_token(PlayerID, Dice, TokenID)
    -> ( token(PlayerID, TokenID, -1)
         -> enter_token_to_board(PlayerID, TokenID)
         ;  move_token_on_board(PlayerID, TokenID, Dice)
       )
    ;  format('Player ~w has no valid moves.~n', [PlayerID])
    ),
    (Dice = 6 -> player_turn(PlayerID) ; true).  % Extra turn on 6

% --- Main Game Round ---
play_all_players :-
    num_players(Total),
    forall(between(1, Total, PlayerID), player_turn(PlayerID)).

% --- Game Entry Point ---
start_game :-
    initialize_tokens,
    play_all_players.