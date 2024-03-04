% ---------------------------------
% Second Eye of Euler -- Jos De Roo
% ---------------------------------
%
% See https://github.com/eyereasoner/see
%

:- use_module(library(lists)).
:- use_module(library(gensym)).
:- use_module(library(system)).
:- use_module(library(terms)).
:- use_module(library(url)).
:- use_module(library(charsio)).
:- use_module(library(qsave)).
:- use_module(library(base64)).
:- use_module(library(date)).
:- use_module(library(prolog_jiti)).
:- use_module(library(sha)).
:- use_module(library(dif)).
:- use_module(library(semweb/turtle)).
:- use_module(library(pcre)).
:- catch(use_module(library(http/http_open)), _, true).

version_info('SEE v0.0.1 (2024-03-03)').

license_info('MIT License

Copyright (c) 2024-2024 Jos De Roo

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.').

help_info('Usage: eye <options>* <data>* <query>*
eye
    swipl -g main see.pl --
<options>
    --debug                         output debug info on stderr
    --help                          show help info
    --image <pvm-file>              output all <data> and all code to <pvm-file>
    --intermediate <n3p-file>       output all <data> to <n3p-file>
    --license                       show license info
    --nope                          no proof explanation
    --output <file>                 write reasoner output to <file>
    --quiet                         quiet mode
    --rdf-list-output               output lists as RDF lists
    --restricted                    restricting to core built-ins
    --skolem-genid <genid>          use <genid> in Skolem IRIs
    --statistics                    output statistics info on stderr
    --strings                       output log:outputString objects on stdout
    --version                       show version info
    --warn                          output warning info on stderr
    --wcache <uri> <file>           to tell that <uri> is cached as <file>
<data>
    <uri>                           TriG data').

:- dynamic(answer/3).               % answer(Predicate, Subject, Object)
:- dynamic(apfx/2).
:- dynamic(argi/1).
:- dynamic(base_uri/1).
:- dynamic(bcnd/2).
:- dynamic(bgot/3).
:- dynamic(brake/0).
:- dynamic(bref/2).
:- dynamic(bvar/1).
:- dynamic(cc/1).
:- dynamic(cpred/1).
:- dynamic(data_fuse/0).
:- dynamic(evar/3).
:- dynamic(exopred/3).              % exopred(Predicate, Subject, Object)
:- dynamic(fact/1).
:- dynamic(flag/1).
:- dynamic(flag/2).
:- dynamic(fpred/1).
:- dynamic(got_cs/1).
:- dynamic(got_dq/0).
:- dynamic(got_head/0).
:- dynamic(got_labelvars/3).
:- dynamic(got_pi/0).
:- dynamic(got_random/3).
:- dynamic(got_sq/0).
:- dynamic(got_unique/2).
:- dynamic(got_wi/5).               % got_wi(Source, Premise, Premise_index, Conclusion, Rule)
:- dynamic(graph/2).
:- dynamic(hash_value/2).
:- dynamic(implies/3).              % implies(Premise, Conclusion, Source)
:- dynamic(input_statements/1).
:- dynamic(intern/1).
:- dynamic(keep_ng/1).
:- dynamic(keep_skolem/1).
:- dynamic(lemma/6).                % lemma(Count, Source, Premise, Conclusion, Premise-Conclusion_index, Rule)
:- dynamic(mtime/2).
:- dynamic(n3s/2).
:- dynamic(ncllit/0).
:- dynamic(nonl/0).
:- dynamic(ns/2).
:- dynamic(parsed_as_n3/2).
:- dynamic(pass_only_new/1).
:- dynamic(pfx/2).
:- dynamic(pred/1).
:- dynamic(prfstep/7).              % prfstep(Conclusion_triple, Premise, Premise_index, Conclusion, Rule, Chaining, Source)
:- dynamic(qevar/3).
:- dynamic(quad/2).
:- dynamic(query/2).
:- dynamic(quvar/3).
:- dynamic(recursion/1).
:- dynamic(retwist/3).
:- dynamic(rule_uvar/1).
:- dynamic(scope/1).
:- dynamic(scount/1).
:- dynamic(semantics/2).
:- dynamic(tabl/3).
:- dynamic(tmpfile/1).
:- dynamic(tuple/2).
:- dynamic(tuple/3).
:- dynamic(tuple/4).
:- dynamic(tuple/5).
:- dynamic(tuple/6).
:- dynamic(tuple/7).
:- dynamic(tuple/8).
:- dynamic(unify/2).
:- dynamic(uuid/2).
:- dynamic(wcache/2).
:- dynamic(wpfx/1).
:- dynamic(wtcache/2).
:- dynamic('<http://eulersharp.sourceforge.net/2003/03swap/log-rules#biconditional>'/2).
:- dynamic('<http://eulersharp.sourceforge.net/2003/03swap/log-rules#call>'/2).
:- dynamic('<http://eulersharp.sourceforge.net/2003/03swap/log-rules#conditional>'/2).
:- dynamic('<http://eulersharp.sourceforge.net/2003/03swap/log-rules#finalize>'/2).
:- dynamic('<http://eulersharp.sourceforge.net/2003/03swap/log-rules#relabel>'/2).
:- dynamic('<http://eulersharp.sourceforge.net/2003/03swap/log-rules#tactic>'/2).
:- dynamic('<http://eulersharp.sourceforge.net/2003/03swap/log-rules#transaction>'/2).
:- dynamic('<http://www.w3.org/1999/02/22-rdf-syntax-ns#first>'/2).
:- dynamic('<http://www.w3.org/1999/02/22-rdf-syntax-ns#rest>'/2).
:- dynamic('<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>'/2).
:- dynamic('<http://www.w3.org/2000/01/rdf-schema#subClassOf>'/2).
:- dynamic('<http://www.w3.org/2000/10/swap/lingua#answer>'/2).
:- dynamic('<http://www.w3.org/2000/10/swap/lingua#bindings>'/2).
:- dynamic('<http://www.w3.org/2000/10/swap/lingua#body>'/2).
:- dynamic('<http://www.w3.org/2000/10/swap/lingua#conclusion>'/2).
:- dynamic('<http://www.w3.org/2000/10/swap/lingua#head>'/2).
:- dynamic('<http://www.w3.org/2000/10/swap/lingua#premise>'/2).
:- dynamic('<http://www.w3.org/2000/10/swap/lingua#question>'/2).
:- dynamic('<http://www.w3.org/2000/10/swap/log#callWithCleanup>'/2).
:- dynamic('<http://www.w3.org/2000/10/swap/log#collectAllIn>'/2).
:- dynamic('<http://www.w3.org/2000/10/swap/log#implies>'/2).
:- dynamic('<http://www.w3.org/2000/10/swap/log#outputString>'/2).
:- dynamic('<http://www.w3.org/2000/10/swap/reason#source>'/2).

%
% Main goal
%

main(Argv) :-
    set_prolog_flag(argv, Argv),
    catch(run, Exc,
        (   Exc = halt(_)
        ->  true
        ;   throw(Exc)
        )
    ).

main :-
    catch(run, Exc,
        (   Exc = halt(EC)
        ->  halt(EC)
        ;   throw(Exc)
        )
    ).

run :-
    nb_setval(fm, 0),
    nb_setval(mf, 0),
    current_prolog_flag(version_data, swi(SV, _, _, _)),
    (   SV < 8
    ->  format(user_error, '** ERROR ** EYE requires at least swipl version 8 **~n', []),
        flush_output(user_error),
        throw(halt(1))
    ;   true
    ),
    catch(set_stream(user_output, encoding(utf8)), _, true),
    current_prolog_flag(argv, Argv),
    (   append(_, ['--'|Argvp], Argv)
    ->  true
    ;   Argvp = Argv
    ),
    (   Argvp = ['--source', File]
    ->  (   File = '-'
        ->  read_line_to_codes(user_input, Codes)
        ;   read_file_to_codes(File, Codes, [])
        ),
        atom_codes(Atom, Codes),
        atomic_list_concat(Argvs, ' ', Atom)
    ;   Argvs = Argvp
    ),
    argv(Argvs, Argus),
    findall(Argij,
        (   argi(Argij)
        ),
        Argil
    ),
    append(Argil, Argi),
    (   member('--quiet', Argus)
    ->  true
    ;   format(user_error, 'eye~@~@~n', [w0(Argi), w1(Argus)]),
        version_info(Version),
        format(user_error, '~w~n', [Version]),
        (   current_prolog_flag(version_git, PVersion)
        ->  true
        ;   current_prolog_flag(version_data, swi(Major, Minor, Patch, Options)),
            (   memberchk(tag(Tag), Options)
            ->  atomic_list_concat([Major, '.', Minor, '.', Patch, '-', Tag], PVersion)
            ;   atomic_list_concat([Major, '.', Minor, '.', Patch], PVersion)
            )
        ),
        format(user_error, 'SWI-Prolog version ~w~n', [PVersion]),
        flush_output(user_error)
    ),
    (   retract(prolog_file_type(qlf, qlf))
    ->  assertz(prolog_file_type(pvm, qlf))
    ;   true
    ),
    (   Argv = ['--n3', _]
    ->  retractall(flag('parse-only')),
        assertz(flag('parse-only'))
    ;   true
    ),
    catch(gre(Argus), Exc,
        (   Exc = halt(0)
        ->  true
        ;   (   flag('parse-only')
            ->  true
            ;   format(user_error, '** ERROR ** gre ** ~w~n', [Exc]),
                flush_output(user_error),
                nb_setval(exit_code, 3)
            )
        )
    ),
    (   flag(statistics)
    ->  statistics
    ;   true
    ),
    (   flag('debug-implies')
    ->  mf(implies(_, _, _))
    ;   true
    ),
    (   flag('debug-pvm')
    ->  tell(user_error),
        ignore(vm_list(_)),
        told,
        (   flag('output', Output)
        ->  tell(Output)
        ;   true
        )
    ;   true
    ),
    (   flag('debug-djiti')
    ->  tell(user_error),
        jiti_list,
        nl,
        told,
        (   flag('output', Output)
        ->  tell(Output)
        ;   true
        )
    ;   true
    ),
    nb_getval(fm, Fm),
    (   Fm = 0
    ->  true
    ;   format(user_error, '*** fm=~w~n', [Fm]),
        flush_output(user_error)
    ),
    nb_getval(mf, Mf),
    (   Mf = 0
    ->  true
    ;   format(user_error, '*** mf=~w~n', [Mf]),
        flush_output(user_error)
    ),
    nb_getval(exit_code, EC),
    flush_output,
    throw(halt(EC)).

argv([], []) :-
    !.
argv([Arg|Argvs], [U, V|Argus]) :-
    sub_atom(Arg, B, 1, E, '='),
    sub_atom(Arg, 0, B, _, U),
    memberchk(U, ['--csv-separator', '--hmac-key', '--image', '--max-inferences', '--n3', '--n3p', '--proof', '--quantify', '--query',  '--output', '--skolem-genid', '--tactic', '--trig', '--turtle']),
    !,
    sub_atom(Arg, _, E, 0, V),
    argv(Argvs, Argus).
argv([Arg|Argvs], [Arg|Argus]) :-
    argv(Argvs, Argus).


% ------------------------------
% GRE (Generic Reasoning Engine)
% ------------------------------

gre(Argus) :-
    statistics(runtime, [T0, _]),
    statistics(walltime, [T1, _]),
    (   member('--quiet', Argus)
    ->  true
    ;   format(user_error, 'starting ~w [msec cputime] ~w [msec walltime]~n', [T0, T1]),
        flush_output(user_error)
    ),
    nb_setval(entail_mode, false),
    nb_setval(exit_code, 0),
    nb_setval(indentation, 0),
    nb_setval(limit, -1),
    nb_setval(bnet, not_done),
    nb_setval(fnet, not_done),
    nb_setval(tabl, -1),
    nb_setval(tuple, -1),
    nb_setval(fdepth, 0),
    nb_setval(pdepth, 0),
    nb_setval(cdepth, 0),
    (   input_statements(Ist)
    ->  nb_setval(input_statements, Ist)
    ;   nb_setval(input_statements, 0)
    ),
    nb_setval(output_statements, 0),
    nb_setval(current_scope, '<>'),
    nb_setval(wn, 0),
    opts(Argus, Args),
    (   Args = []
    ->  opts(['--help'], _)
    ;   true
    ),
    (   flag('skolem-genid', Genid)
    ->  true
    ;   uuid(Genid)
    ),
    atomic_list_concat(['http://eyereasoner.github.io/.well-known/genid/', Genid, '#'], Sns),
    nb_setval(var_ns, Sns),
    (   (   flag(strings)
        ;   flag(image, _)
        )
    ->  true
    ;   version_info(Version),
        (   flag(quiet)
        ->  true
        ;   (   flag('n3p-output')
            ->  format('% Processed by ~w~n', [Version])
            ;   format('# Processed by ~w~n', [Version])
            )
        ),
        findall(Argij,
            (   argi(Argij)
            ),
            Argil
        ),
        append(Argil, Argi),
        (   flag(quiet)
        ->  true
        ;   (   flag('n3p-output')
            ->  format('% eye~@~@~n~n', [w0(Argi), w1(Argus)])
            ;   format('# eye~@~@~n~n', [w0(Argi), w1(Argus)])
            ),
            flush_output
        )
    ),
    (   (   flag('no-qvars')
        ;   flag('pass-all-ground')
        )
    ->  retractall(pfx('var:', _)),
        assertz(pfx('var:', '<http://www.w3.org/2000/10/swap/var#>'))
    ;   true
    ),
    (   flag(intermediate, Out)
    ->  format(Out, 'flag(\'quantify\', \'~w\').~n', [Sns])
    ;   true
    ),
    args(Args),
    (   flag(see)
    ->  see
    ;   init
    ),
    (   implies(_, Conc, _),
        (   var(Conc)
        ;   Conc \= answer(_, _, _),
            Conc \= (answer(_, _, _), _)
        )
    ->  true
    ;   (   \+flag(image, _),
            \+flag(tactic, 'linear-select')
        ->  assertz(flag(tactic, 'linear-select'))
        ;   true
        )
    ),
    findall(Sc,
        (   scope(Sc)
        ),
        Scope
    ),
    nb_setval(scope, Scope),
    statistics(runtime, [_, T2]),
    statistics(walltime, [_, T3]),
    (   flag(quiet)
    ->  true
    ;   format(user_error, 'networking ~w [msec cputime] ~w [msec walltime]~n', [T2, T3]),
        flush_output(user_error)
    ),
    nb_getval(input_statements, SC),
    (   flag(image, File)
    ->  assertz(argi(Argus)),
        retractall(flag(image, _)),
        assertz(flag('quantify', Sns)),
        retractall(input_statements(_)),
        assertz(input_statements(SC)),
        reset_gensym,
        (   current_predicate(qsave:qsave_program/1)
        ->  qsave_program(File)
        ;   save_program(File)
        ),
        throw(halt(0))
    ;   true
    ),
    (   flag(intermediate, Out)
    ->  (   SC =\= 0
        ->  write(Out, scount(SC)),
            writeln(Out, '.')
        ;   true
        ),
        writeln(Out, 'end_of_file.'),
        close(Out)
    ;   true
    ),
    (   \+implies(_, answer(_, _, _), _),
        \+implies(_, (answer(_, _, _), _), _),
        \+query(_, _),
        \+flag('pass-only-new'),
        \+flag(strings),
        \+flag(see)
    ->  throw(halt(0))
    ;   true
    ),
    (   pfx('r:', _)
    ->  true
    ;   assertz(pfx('r:', '<http://www.w3.org/2000/10/swap/reason#>'))
    ),
    (   pfx('var:', _)
    ->  true
    ;   assertz(pfx('var:', '<http://www.w3.org/2000/10/swap/var#>'))
    ),
    (   pfx('skolem:', _)
    ->  true
    ;   nb_getval(var_ns, Sns),
        atomic_list_concat(['<', Sns, '>'], B),
        assertz(pfx('skolem:', B))
    ),
    (   pfx('n3:', _)
    ->  true
    ;   assertz(pfx('n3:', '<http://www.w3.org/2004/06/rei#>'))
    ),
    nb_setval(tr, 0),
    nb_setval(tc, 0),
    nb_setval(tp, 0),
    nb_setval(rn, 0),
    nb_setval(lemma_count, 0),
    nb_setval(lemma_cursor, 0),
    nb_setval(answer_count, 0),
    nb_setval(keep_ng, true),
    (   flag(profile)
    ->  asserta(pce_profile:pce_show_profile :- fail),
        profile(eam(0))
    ;   catch(eam(0), Exc3,
            (   (   Exc3 = halt(0)
                ->  true
                ;   format(user_error, '** ERROR ** eam ** ~w~n', [Exc3]),
                    flush_output(user_error),
                    (   Exc3 = inference_fuse(_)
                    ->  nb_setval(exit_code, 2)
                    ;   nb_setval(exit_code, 3)
                    )
                )
            )
        )
    ),
    (   flag('pass-only-new')
    ->  open_null_stream(Ws),
        tell(Ws),
        w2,
        retractall(pfx(_, _)),
        retractall(wpfx(_)),
        nb_setval(lemma_cursor, 0),
        forall(
            apfx(Pfx, Uri),
            assertz(pfx(Pfx, Uri))
        ),
        told,
        (   flag('output', Output)
        ->  tell(Output)
        ;   true
        ),
        w2
    ;   true
    ),
    (   flag(strings)
    ->  wst
    ;   true
    ),
    nb_getval(tc, TC),
    nb_getval(tp, TP),
    statistics(runtime, [_, T4]),
    statistics(walltime, [_, T5]),
    (   flag(quiet)
    ->  true
    ;   format(user_error, 'reasoning ~w [msec cputime] ~w [msec walltime]~n', [T4, T5]),
        flush_output(user_error)
    ),
    nb_getval(input_statements, Inp),
    nb_getval(output_statements, Outp),
    timestamp(Stamp),
    Ent is TC,
    Step is TP,
    statistics(runtime, [Cpu, _]),
    nb_getval(tr, TR),
    Brake is TR,
    (   statistics(inferences, Inf)
    ->  true
    ;   Inf = ''
    ),
    catch(Speed is round(Inf/Cpu*1000), _, Speed = ''),
    (   (   flag(strings)
        ;   flag(quiet)
        )
    ->  true
    ;   (   flag('n3p-output')
        ->  format('% ~w in=~d out=~d ent=~d step=~w brake=~w inf=~w sec=~3d inf/sec=~w~n% ENDS~n~n', [Stamp, Inp, Outp, Ent, Step, Brake, Inf, Cpu, Speed])
        ;   format('# ~w in=~d out=~d ent=~d step=~w brake=~w inf=~w sec=~3d inf/sec=~w~n# ENDS~n~n', [Stamp, Inp, Outp, Ent, Step, Brake, Inf, Cpu, Speed])
        )
    ),
    (   flag(quiet)
    ->  true
    ;   format(user_error, '~w in=~d out=~d ent=~d step=~w brake=~w inf=~w sec=~3d inf/sec=~w~n~n', [Stamp, Inp, Outp, Ent, Step, Brake, Inf, Cpu, Speed]),
        flush_output(user_error)
    ),
    (   flag('rule-histogram')
    ->  findall([RTC, RTP, R],
            (   tabl(ETP, tp, Rule),
                nb_getval(ETP, RTP),
                (   tabl(ETC, tc, Rule)
                ->  nb_getval(ETC, RTC)
                ;   RTC = 0
                ),
                with_output_to(atom(R), wt(Rule))
            ),
            CntRl
        ),
        sort(CntRl, CntRs),
        reverse(CntRs, CntRr),
        format(user_error, '>>> rule histogram TR=~w <<<~n', [TR]),
        forall(
            member(RCnt, CntRr),
            (   (   last(RCnt, '<http://www.w3.org/2000/10/swap/log#implies>'(X, Y)),
                    conj_append(X, pstep(_), Z),
                    catch(clause(Y, Z), _, fail)
                ->  format(user_error, 'TC=~w TP=~w for component ~w~n', RCnt)
                ;   format(user_error, 'TC=~w TP=~w for rule ~w~n', RCnt)
                )
            )
        ),
        format(user_error, '~n', []),
        flush_output(user_error)
    ;   true
    ).

% init for N3
init :-
    % create quads
    (   retract(graph(N, G)),
        conj_list(G, L),
        forall(
            (   member(M, L),
                M =.. [P, S, O]
            ),
            assertz(quad(triple(S, P, O), N))
        ),
        fail
    ;   true
    ).

%
% Second Eye of Euler - SEE
% Supporting RDF Lingua
%
% RDF as the web talking language
% Reasoning with rules described in RDF

see :-
    % configure
    (   \+flag(nope)
    ->  assertz(flag(nope)),
        assertz(flag(explain))
    ;   true
    ),
    % create named graphs
    (   quad(_, A),
        findall(C,
            (   retract(quad(triple(S, P, O), A)),
                C =.. [P, S, O]
            ),
            D
        ),
        D \= [],
        conjoin(D, E),
        assertz(graph(A, E)),
        fail
    ;   true
    ),
    (   graph(A, B),
        conj_list(B, C),
        relist(C, D),
        conj_list(E, D),
        E \= B,
        retract(graph(A, B)),
        assertz(graph(A, E)),
        fail
    ;   true
    ),
    % create terms
    (   pred(P),
        P \= '<http://www.w3.org/1999/02/22-rdf-syntax-ns#first>',
        P \= '<http://www.w3.org/1999/02/22-rdf-syntax-ns#rest>',
        X =.. [P, _, _],
        call(X),
        getterm(X, Y),
        (   Y = X
        ->  true
        ;   retract(X),
            assertz(Y)
        ),
        fail
    ;   true
    ),
    \+flag('pass-merged'),
    % forward rule
    assertz(implies((
            '<http://www.w3.org/2000/10/swap/lingua#premise>'(R, A),
            '<http://www.w3.org/2000/10/swap/lingua#conclusion>'(R, B),
            findvars([A, B], V, alpha),
            list_to_set(V, U),
            makevars([A, B, U], [Q, I, X], beta(U)),
            (   flag(explain),
                I \= false
            ->  zip_list(U, X, W),
                conj_append(I, remember(answer('<http://www.w3.org/2000/10/swap/lingua#premise>', R, A)), D),
                conj_append(D, remember(answer('<http://www.w3.org/2000/10/swap/lingua#conclusion>', R, B)), E),
                conj_append(E, remember(answer('<http://www.w3.org/2000/10/swap/lingua#bindings>', R, W)), F)
            ;   F = I
            )), '<http://www.w3.org/2000/10/swap/log#implies>'(Q, F), '<>')),
    % backward rule
    assertz(implies((
            '<http://www.w3.org/2000/10/swap/lingua#body>'(R, A),
            '<http://www.w3.org/2000/10/swap/lingua#head>'(R, B),
            findvars([A, B], V, alpha),
            list_to_set(V, U),
            makevars([A, B, U], [Q, I, X], beta(U)),
            (   flag(explain)
            ->  zip_list(U, X, W),
                conj_append(Q, remember(answer('<http://www.w3.org/2000/10/swap/lingua#body>', R, A)), D),
                conj_append(D, remember(answer('<http://www.w3.org/2000/10/swap/lingua#head>', R, B)), E),
                conj_append(E, remember(answer('<http://www.w3.org/2000/10/swap/lingua#bindings>', R, W)), F)
            ;   F = Q
            ),
            C = ':-'(I, F),
            copy_term_nat(C, CC),
            labelvars(CC, 0, _, avar),
            (   \+cc(CC)
            ->  assertz(cc(CC)),
                assertz(C),
                retractall(brake)
            ;   true
            )), true, '<>')),
    % query
    assertz(implies((
            '<http://www.w3.org/2000/10/swap/lingua#question>'(R, A),
            (   '<http://www.w3.org/2000/10/swap/lingua#answer>'(R, B)
            ->  true
            ;   B = A
            ),
            djiti_answer(answer(B), J),
            findvars([A, B], V, alpha),
            list_to_set(V, U),
            makevars([A, J, U], [Q, I, X], beta(U)),
            (   flag(explain)
            ->  zip_list(U, X, W),
                conj_append(Q, remember(answer('<http://www.w3.org/2000/10/swap/lingua#question>', R, A)), D),
                conj_append(D, remember(answer('<http://www.w3.org/2000/10/swap/lingua#answer>', R, B)), E),
                conj_append(E, remember(answer('<http://www.w3.org/2000/10/swap/lingua#bindings>', R, W)), F)
            ;   F = Q
            ),
            C = implies(F, I, '<>'),
            copy_term_nat(C, CC),
            labelvars(CC, 0, _, avar),
            (   \+cc(CC)
            ->  assertz(cc(CC)),
                assertz(C),
                retractall(brake)
            ;   true
            )), true, '<>')).
see.

%
% command line options
%

opts([], []) :-
    !.
opts(['--csv-separator', Separator|Argus], Args) :-
    !,
    retractall(flag('csv-separator')),
    assertz(flag('csv-separator', Separator)),
    opts(Argus, Args).
opts(['--debug'|Argus], Args) :-
    !,
    retractall(flag(debug)),
    assertz(flag(debug)),
    opts(Argus, Args).
opts(['--debug-cnt'|Argus], Args) :-
    !,
    retractall(flag('debug-cnt')),
    assertz(flag('debug-cnt')),
    opts(Argus, Args).
opts(['--debug-djiti'|Argus], Args) :-
    !,
    retractall(flag('debug-djiti')),
    assertz(flag('debug-djiti')),
    opts(Argus, Args).
opts(['--debug-implies'|Argus], Args) :-
    !,
    retractall(flag('debug-implies')),
    assertz(flag('debug-implies')),
    opts(Argus, Args).
opts(['--debug-pvm'|Argus], Args) :-
    !,
    retractall(flag('debug-pvm')),
    assertz(flag('debug-pvm')),
    opts(Argus, Args).
opts(['--help'|_], _) :-
    \+flag(image, _),
    \+flag('debug-pvm'),
    !,
    help_info(Help),
    format(user_error, '~w~n', [Help]),
    flush_output(user_error),
    throw(halt(0)).
opts(['--hmac-key', Key|Argus], Args) :-
    !,
    retractall(flag('hmac-key', _)),
    assertz(flag('hmac-key', Key)),
    opts(Argus, Args).
opts(['--ignore-inference-fuse'|Argus], Args) :-
    !,
    retractall(flag('ignore-inference-fuse')),
    assertz(flag('ignore-inference-fuse')),
    opts(Argus, Args).
opts(['--image', File|Argus], Args) :-
    !,
    retractall(flag(image, _)),
    assertz(flag(image, File)),
    opts(Argus, Args).
opts(['--legacy'|Argus], Args) :-
    !,
    retractall(flag(legacy)),
    assertz(flag(legacy)),
    opts(Argus, Args).
opts(['--license'|_], _) :-
    !,
    license_info(License),
    format(user_error, '~w~n', [License]),
    flush_output(user_error),
    throw(halt(0)).
opts(['--max-inferences', Lim|Argus], Args) :-
    !,
    (   number(Lim)
    ->  Limit = Lim
    ;   catch(atom_number(Lim, Limit), Exc,
            (   format(user_error, '** ERROR ** max-inferences ** ~w~n', [Exc]),
                flush_output(user_error),
                flush_output,
                throw(halt(1))
            )
        )
    ),
    retractall(flag('max-inferences', _)),
    assertz(flag('max-inferences', Limit)),
    opts(Argus, Args).
opts(['--n3p-output'|Argus], Args) :-
    !,
    retractall(flag('n3p-output')),
    assertz(flag('n3p-output')),
    opts(Argus, Args).
opts(['--no-beautified-output'|Argus], Args) :-
    !,
    retractall(flag('no-beautified-output')),
    assertz(flag('no-beautified-output')),
    opts(Argus, Args).
opts(['--no-distinct-input'|Argus], Args) :-
    !,
    retractall(flag('no-distinct-input')),
    assertz(flag('no-distinct-input')),
    opts(Argus, Args).
opts(['--no-distinct-output'|Argus], Args) :-
    !,
    retractall(flag('no-distinct-output')),
    assertz(flag('no-distinct-output')),
    opts(Argus, Args).
opts(['--no-numerals'|Argus], Args) :-
    !,
    retractall(flag('no-numerals')),
    assertz(flag('no-numerals')),
    opts(Argus, Args).
opts(['--no-qnames'|Argus], Args) :-
    !,
    retractall(flag('no-qnames')),
    assertz(flag('no-qnames')),
    opts(Argus, Args).
opts(['--no-qvars'|Argus], Args) :-
    !,
    retractall(flag('no-qvars')),
    assertz(flag('no-qvars')),
    opts(Argus, Args).
opts(['--no-ucall'|Argus], Args) :-
    !,
    retractall(flag('no-ucall')),
    assertz(flag('no-ucall')),
    opts(Argus, Args).
opts(['--nope'|Argus], Args) :-
    !,
    retractall(flag(nope)),
    assertz(flag(nope)),
    opts(Argus, Args).
opts(['--output', File|Argus], Args) :-
    !,
    retractall(flag('output', _)),
    open(File, write, Out, [encoding(utf8)]),
    tell(Out),
    assertz(flag('output', Out)),
    opts(Argus, Args).
opts(['--pass-all-ground'|Argus], Args) :-
    !,
    retractall(flag('pass-all-ground')),
    assertz(flag('pass-all-ground')),
    opts(['--pass-all'|Argus], Args).
opts(['--pass-merged'|Argus], Args) :-
    !,
    retractall(flag('pass-merged')),
    assertz(flag('pass-merged')),
    opts(['--pass-all'|Argus], Args).
opts(['--pass-only-new'|Argus], Args) :-
    !,
    retractall(flag('pass-only-new')),
    assertz(flag('pass-only-new')),
    opts(Argus, Args).
opts(['--intermediate', File|Argus], Args) :-
    !,
    retractall(flag(intermediate, _)),
    open(File, write, Out, [encoding(utf8)]),
    assertz(flag(intermediate, Out)),
    opts(Argus, Args).
opts(['--profile'|Argus], Args) :-
    !,
    retractall(flag(profile)),
    assertz(flag(profile)),
    opts(Argus, Args).
opts(['--quantify', Prefix|Argus], Args) :-
    !,
    assertz(flag('quantify', Prefix)),
    opts(Argus, Args).
opts(['--quiet'|Argus], Args) :-
    !,
    retractall(flag(quiet)),
    assertz(flag(quiet)),
    opts(Argus, Args).
opts(['--random-seed'|Argus], Args) :-
    !,
    N is random(2^120),
    nb_setval(random, N),
    opts(Argus, Args).
opts(['--no-bnode-relabeling'|Argus], Args) :-
    !,
    retractall(flag('no-bnode-relabeling')),
    assertz(flag('no-bnode-relabeling')),
    opts(Argus, Args).
opts(['--rdf-list-output'|Argus], Args) :-
    !,
    retractall(flag('rdf-list-output')),
    assertz(flag('rdf-list-output')),
    opts(Argus, Args).
opts(['--restricted'|Argus], Args) :-
    !,
    retractall(flag(restricted)),
    assertz(flag(restricted)),
    opts(Argus, Args).
opts(['--rule-histogram'|Argus], Args) :-
    !,
    retractall(flag('rule-histogram')),
    assertz(flag('rule-histogram')),
    opts(Argus, Args).
opts(['--skolem-genid', Genid|Argus], Args) :-
    !,
    retractall(flag('skolem-genid', _)),
    assertz(flag('skolem-genid', Genid)),
    opts(Argus, Args).
opts(['--statistics'|Argus], Args) :-
    !,
    retractall(flag(statistics)),
    assertz(flag(statistics)),
    opts(Argus, Args).
opts(['--strings'|Argus], Args) :-
    !,
    retractall(flag(strings)),
    assertz(flag(strings)),
    opts(Argus, Args).
opts(['--tactic', 'limited-answer', Lim|Argus], Args) :-
    !,
    (   number(Lim)
    ->  Limit = Lim
    ;   catch(atom_number(Lim, Limit), Exc,
            (   format(user_error, '** ERROR ** limited-answer ** ~w~n', [Exc]),
                flush_output(user_error),
                flush_output,
                throw(halt(1))
            )
        )
    ),
    retractall(flag('limited-answer', _)),
    assertz(flag('limited-answer', Limit)),
    opts(Argus, Args).
opts(['--tactic', 'linear-select'|Argus], Args) :-
    !,
    retractall(flag(tactic, 'linear-select')),
    assertz(flag(tactic, 'linear-select')),
    opts(Argus, Args).
opts(['--tactic', Tactic|_], _) :-
    !,
    throw(not_supported_tactic(Tactic)).
opts(['--version'|_], _) :-
    !,
    throw(halt(0)).
opts(['--warn'|Argus], Args) :-
    !,
    retractall(flag(warn)),
    assertz(flag(warn)),
    opts(Argus, Args).
opts(['--wcache', Argument, File|Argus], Args) :-
    !,
    absolute_uri(Argument, Arg),
    retractall(wcache(Arg, _)),
    assertz(wcache(Arg, File)),
    opts(Argus, Args).
opts([Arg|_], _) :-
    \+memberchk(Arg, ['--entail', '--help', '--n3', '--n3p', '--not-entail', '--pass', '--pass-all', '--proof', '--query', '--trig', '--turtle']),
    sub_atom(Arg, 0, 2, _, '--'),
    !,
    throw(not_supported_option(Arg)).
opts([Arg|Argus], [Arg|Args]) :-
    opts(Argus, Args).

args([]) :-
    !.
args([Argument|Args]) :-
    !,
    absolute_uri(Argument, Arg),
    atomic_list_concat(['<', Arg, '>'], R),
    assertz(scope(R)),
    (   flag(intermediate, Out)
    ->  portray_clause(Out, scope(R))
    ;   true
    ),
    (   wcacher(Arg, File)
    ->  (   flag(quiet)
        ->  true
        ;   format(user_error, 'GET ~w FROM ~w ', [Arg, File]),
            flush_output(user_error)
        ),
        open(File, read, In, [encoding(utf8)])
    ;   (   flag(quiet)
        ->  true
        ;   format(user_error, 'GET ~w ', [Arg]),
            flush_output(user_error)
        ),
        (   (   sub_atom(Arg, 0, 5, _, 'http:')
            ->  true
            ;   sub_atom(Arg, 0, 6, _, 'https:')
            )
        ->  http_open(Arg, In, []),
            set_stream(In, encoding(utf8))
        ;   (   sub_atom(Arg, 0, 5, _, 'file:')
            ->  (   parse_url(Arg, Parts)
                ->  memberchk(path(File), Parts)
                ;   sub_atom(Arg, 7, _, 0, File)
                )
            ;   File = Arg
            ),
            (   File = '-'
            ->  In = user_input
            ;   open(File, read, In, [encoding(utf8)])
            )
        )
    ),
    retractall(base_uri(_)),
    (   Arg = '-'
    ->  absolute_uri('', Abu),
        assertz(base_uri(Abu))
    ;   assertz(base_uri(Arg))
    ),
    retractall(ns(_, _)),
    (   Arg = '-'
    ->  D = '#'
    ;   atomic_list_concat([Arg, '#'], D)
    ),
    assertz(ns('', D)),
    nb_getval(var_ns, Sns),
    assertz(ns(skolem, Sns)),
    nb_setval(sc, 0),
    rdf_read_turtle(stream(In), Triples, [base_uri(Arg), format(trig), prefixes(Pfxs), on_error(error)]),
    close(In),
    forall(
        member(Pfx-Ns, Pfxs),
        put_pfx(Pfx, Ns)
    ),
    put_pfx('', D),
    forall(
        member(rdf(S, P, O), Triples),
        (   ttl_n3p(S, Subject),
            ttl_n3p(P, Predicate),
            ttl_n3p(O, Object),
            Triple =.. [Predicate, Subject, Object],
            djiti_assertz(Triple),
            (   flag(intermediate, Out)
            ->  format(Out, '~q.~n', [Triple])
            ;   true
            ),
            (   flag(nope)
            ->  true
            ;   assertz(prfstep(Triple, true, _, Triple, _, forward, R))
            )
        )
    ),
    forall(
        member(rdf(S, P, O, G), Triples),
        (   ttl_n3p(S, Subject),
            ttl_n3p(P, Predicate),
            ttl_n3p(O, Object),
            G = H:_,
            ttl_n3p(H, Graph),
            assertz(quad(triple(Subject, Predicate, Object), Graph))
        )
    ),
    length(Triples, SC),
    nb_getval(input_statements, IN),
    Inp is SC+IN,
    nb_setval(input_statements, Inp),
    (   flag(quiet)
    ->  true
    ;   format(user_error, 'SC=~w~n', [SC]),
        flush_output(user_error)
    ),
    args(Args).

n3pin(Rt, In, File, Mode) :-
    (   Rt = ':-'(Rg)
    ->  (   flag('parse-only')
        ->  true
        ;   call(Rg)
        ),
        (   flag(intermediate, Out)
        ->  format(Out, '~q.~n', [Rt])
        ;   true
        )
    ;   dynify(Rt),
        (   (   Rt = ':-'(Rh, _)
            ->  predicate_property(Rh, dynamic)
            ;   predicate_property(Rt, dynamic)
            )
        ->  true
        ;   (   File = '-'
            ->  true
            ;   close(In)
            ),
            (   retract(tmpfile(File))
            ->  delete_file(File)
            ;   true
            ),
            throw(builtin_redefinition(Rt))
        ),
        (   Rt = pfx(Pfx, _)
        ->  retractall(pfx(Pfx, _))
        ;   true
        ),
        (   Rt = scope(Scope)
        ->  nb_setval(current_scope, Scope)
        ;   true
        ),
        (   Rt = ':-'(Ci, Px),
            conjify(Px, Pi)
        ->  (   Ci = true
            ->  (   flag('parse-only')
                ->  true
                ;   call(Pi)
                )
            ;   nb_getval(current_scope, Si),
                copy_term_nat('<http://www.w3.org/2000/10/swap/log#implies>'(Pi, Ci), Ri),
                (   flag(nope)
                ->  Ph = Pi
                ;   (   Pi = when(Ai, Bi)
                    ->  conj_append(Bi, istep(Si, Pi, Ci, Ri), Bh),
                        Ph = when(Ai, Bh)
                    ;   conj_append(Pi, istep(Si, Pi, Ci, Ri), Ph)
                    )
                ),
                (   flag('rule-histogram')
                ->  (   Ph = when(Ak, Bk)
                    ->  conj_append(Bk, pstep(Ri), Bj),
                        Pj = when(Ak, Bj)
                    ;   conj_append(Ph, pstep(Ri), Pj)
                    )
                ;   Pj = Ph
                ),
                functor(Ci, CPi, _),
                (   flag(intermediate, Out)
                ->  (   \+cpred(CPi)
                    ->  portray_clause(Out, cpred(CPi))
                    ;   true
                    ),
                    portray_clause(Out, ':-'(Ci, Pi))
                ;   true
                ),
                (   \+cpred(CPi)
                ->  assertz(cpred(CPi))
                ;   true
                ),
                assertz(':-'(Ci, Pj))
            )
        ;   (   Rt \= implies(_, _, _),
                Rt \= scount(_),
                Rt \= '<http://www.w3.org/1999/02/22-rdf-syntax-ns#first>'(_, _),
                Rt \= '<http://www.w3.org/1999/02/22-rdf-syntax-ns#rest>'(_, _),
                \+flag('no-distinct-input'),
                call(Rt)
            ->  true
            ;   (   Rt \= pred('<http://eulersharp.sourceforge.net/2003/03swap/log-rules#relabel>'),
                    \+ (Rt = scope(_), Mode = query)
                ->  djiti_assertz(Rt),
                    (   flag(intermediate, Out),
                        Rt \= scount(_)
                    ->  format(Out, '~q.~n', [Rt])
                    ;   true
                    ),
                    (   Rt \= flag(_, _),
                        Rt \= scope(_),
                        Rt \= pfx(_, _),
                        Rt \= pred(_),
                        Rt \= cpred(_),
                        Rt \= scount(_)
                    ->  (   flag(nope)
                        ->  true
                        ;   term_index(true, Pnd),
                            nb_getval(current_scope, Src),
                            assertz(prfstep(Rt, true, Pnd, Rt, _, forward, Src))
                        )
                    ;   true
                    )
                ;   true
                )
            )
        )
    ).

ttl_n3p(literal(type(A, B)), C) :-
    memberchk(A, ['http://www.w3.org/2001/XMLSchema#integer', 'http://www.w3.org/2001/XMLSchema#long', 'http://www.w3.org/2001/XMLSchema#decimal', 'http://www.w3.org/2001/XMLSchema#double']),
    atom_number(B, C),
    !.
ttl_n3p(literal(type('http://www.w3.org/2001/XMLSchema#boolean', A)), A) :-
    !.
ttl_n3p(literal(type(A, B)), literal(E, type(F))) :-
    atom_codes(B, C),
    escape_string(C, D),
    atom_codes(E, D),
    atomic_list_concat(['<', A, '>'], F),
    !.
ttl_n3p(literal(lang(A, B)), literal(E, lang(A))) :-
    atom_codes(B, C),
    escape_string(C, D),
    atom_codes(E, D),
    !.
ttl_n3p(literal(A), literal(E, type('<http://www.w3.org/2001/XMLSchema#string>'))) :-
    atom_codes(A, C),
    escape_string(C, D),
    atom_codes(E, D),
    !.
ttl_n3p(node(A), B) :-
    !,
    nb_getval(var_ns, Sns),
    atomic_list_concat(['<', Sns, 'node_', A, '>'], B).
ttl_n3p(A, B) :-
    (   atom_concat('http://www.w3.org/2000/10/swap/lingua#', _, A),
        \+flag(see)
    ->  assertz(flag(see))
    ;   true
    ),
    atomic_list_concat(['<', A, '>'], B).

rename('\'<http://www.w3.org/1999/02/22-rdf-syntax-ns#nil>\'', []) :-
    !.
rename('\'<http://www.w3.org/2000/10/swap/log#isImpliedBy>\'', ':-') :-
    !.
rename(A, A).

number_n(0'-, In, CN, numeric(T, [0'-|Codes])) :-
    !,
    get_code(In, C0),
    number_nn(C0, In, CN, numeric(T, Codes)).
number_n(0'+, In, CN, numeric(T, [0'+|Codes])) :-
    !,
    get_code(In, C0),
    number_nn(C0, In, CN, numeric(T, Codes)).
number_n(C0, In, CN, Value) :-
    number_nn(C0, In, CN, Value).

number_nn(C, In, CN, numeric(Type, Codes)) :-
    integer_codes(C, In, CN0, Codes, T0),
    (   CN0 == 0'.,
        peek_code(In, C0),
        (   e(C0)
        ->  T1 = [0'0|T2],
            get_code(In, CN1)
        ;   0'0 =< C0,
            C0 =< 0'9,
            get_code(In, C1),
            integer_codes(C1, In, CN1, T1, T2)
        ),
        T0 = [0'.|T1]
    ->  (   exponent(CN1, In, CN, T2)
        ->  Type = double
        ;   CN = CN1,
            T2 = [],
            Type = decimal
        )
    ;   (   exponent(CN0, In, CN, T0)
        ->  Type = double
        ;   T0 = [],
            CN = CN0,
            Type = integer
        )
    ).

integer_codes(C0, In, CN, [C0|T0], T) :-
    0'0 =< C0,
    C0 =< 0'9,
    !,
    get_code(In, C1),
    integer_codes(C1, In, CN, T0, T).
integer_codes(CN, _, CN, T, T).

exponent(C0, In, CN, [C0|T0]) :-
    e(C0),
    !,
    get_code(In, C1),
    optional_sign(C1, In, CN0, T0, T1),
    integer_codes(CN0, In, CN, T1, []),
    (   T1 = []
    ->  nb_getval(line_number, Ln),
        throw(invalid_exponent(line(Ln)))
    ;   true
    ).

optional_sign(C0, In, CN, [C0|T], T) :-
    sign(C0),
    !,
    get_code(In, CN).
optional_sign(CN, _, CN, T, T).

e(0'e).
e(0'E).

sign(0'-).
sign(0'+).

dq_string(-1, _, _, []) :-
    !,
    nb_getval(line_number, Ln),
    throw(unexpected_end_of_input(line(Ln))).
dq_string(0'", In, C, []) :-
    (   retract(got_dq)
    ->  true
    ;   peek_code(In, 0'"),
        get_code(In, _)
    ),
    (   retract(got_dq)
    ->  assertz(got_dq)
    ;   assertz(got_dq),
        peek_code(In, 0'"),
        get_code(In, _),
        assertz(got_dq)
    ),
    !,
    (   peek_code(In, 0'")
    ->  nb_getval(line_number, Ln),
        throw(unexpected_double_quote(line(Ln)))
    ;   true
    ),
    retractall(got_dq),
    get_code(In, C).
dq_string(0'", In, C, [0'"|T]) :-
    !,
    (   retract(got_dq)
    ->  C1 = 0'"
    ;   get_code(In, C1)
    ),
    dq_string(C1, In, C, T).
dq_string(0'\\, In, C, [H|T]) :-
    (   retract(got_dq)
    ->  C1 = 0'"
    ;   get_code(In, C1)
    ),
    !,
    string_escape(C1, In, C2, H),
    dq_string(C2, In, C, T).
dq_string(C0, In, C, [C0|T]) :-
    (   retract(got_dq)
    ->  C1 = 0'"
    ;   get_code(In, C1)
    ),
    dq_string(C1, In, C, T).

sq_string(-1, _, _, []) :-
    !,
    nb_getval(line_number, Ln),
    throw(unexpected_end_of_input(line(Ln))).
sq_string(0'', In, C, []) :-
    (   retract(got_sq)
    ->  true
    ;   peek_code(In, 0''),
        get_code(In, _)
    ),
    (   retract(got_sq)
    ->  assertz(got_sq)
    ;   assertz(got_sq),
        peek_code(In, 0''),
        get_code(In, _),
        assertz(got_sq)
    ),
    !,
    (   peek_code(In, 0'')
    ->  nb_getval(line_number, Ln),
        throw(unexpected_single_quote(line(Ln)))
    ;   true
    ),
    retractall(got_sq),
    get_code(In, C).
sq_string(0'', In, C, [0''|T]) :-
    !,
    (   retract(got_sq)
    ->  C1 = 0''
    ;   get_code(In, C1)
    ),
    sq_string(C1, In, C, T).
sq_string(0'\\, In, C, [H|T]) :-
    (   retract(got_sq)
    ->  C1 = 0''
    ;   get_code(In, C1)
    ),
    !,
    string_escape(C1, In, C2, H),
    sq_string(C2, In, C, T).
sq_string(C0, In, C, [C0|T]) :-
    (   retract(got_sq)
    ->  C1 = 0''
    ;   get_code(In, C1)
    ),
    sq_string(C1, In, C, T).

string_dq(-1, _, _, []) :-
    !,
    nb_getval(line_number, Ln),
    throw(unexpected_end_of_input(line(Ln))).
string_dq(0'\n, _, _, []) :-
    !,
    nb_getval(line_number, Ln),
    throw(unexpected_end_of_line(line(Ln))).
string_dq(0'", In, C, []) :-
    !,
    get_code(In, C).
string_dq(0'\\, In, C, D) :-
    get_code(In, C1),
    !,
    string_escape(C1, In, C2, H),
    (   current_prolog_flag(windows, true),
        H > 0xFFFF
    ->  E is (H-0x10000)>>10+0xD800,
        F is (H-0x10000) mod 0x400+0xDC00,
        D = [E, F|T]
    ;   D = [H|T]
    ),
    string_dq(C2, In, C, T).
string_dq(C0, In, C, D) :-
    (   current_prolog_flag(windows, true),
        C0 > 0xFFFF
    ->  E is (C0-0x10000)>>10+0xD800,
        F is (C0-0x10000) mod 0x400+0xDC00,
        D = [E, F|T]
    ;   D = [C0|T]
    ),
    get_code(In, C1),
    string_dq(C1, In, C, T).

string_sq(-1, _, _, []) :-
    !,
    nb_getval(line_number, Ln),
    throw(unexpected_end_of_input(line(Ln))).
string_sq(0'', In, C, []) :-
    !,
    get_code(In, C).
string_sq(0'\\, In, C, D) :-
    get_code(In, C1),
    !,
    string_escape(C1, In, C2, H),
    (   current_prolog_flag(windows, true),
        H > 0xFFFF
    ->  E is (H-0x10000)>>10+0xD800,
        F is (H-0x10000) mod 0x400+0xDC00,
        D = [E, F|T]
    ;   D = [H|T]
    ),
    string_sq(C2, In, C, T).
string_sq(C0, In, C, D) :-
    (   current_prolog_flag(windows, true),
        C0 > 0xFFFF
    ->  E is (C0-0x10000)>>10+0xD800,
        F is (C0-0x10000) mod 0x400+0xDC00,
        D = [E, F|T]
    ;   D = [C0|T]
    ),
    get_code(In, C1),
    string_sq(C1, In, C, T).

string_escape(0't, In, C, 0'\t) :-
    !,
    get_code(In, C).
string_escape(0'b, In, C, 0'\b) :-
    !,
    get_code(In, C).
string_escape(0'n, In, C, 0'\n) :-
    !,
    get_code(In, C).
string_escape(0'r, In, C, 0'\r) :-
    !,
    get_code(In, C).
string_escape(0'f, In, C, 0'\f) :-
    !,
    get_code(In, C).
string_escape(0'", In, C, 0'") :-
    !,
    get_code(In, C).
string_escape(0'', In, C, 0'') :-
    !,
    get_code(In, C).
string_escape(0'\\, In, C, 0'\\) :-
    !,
    get_code(In, C).
string_escape(0'u, In, C, Code) :-
    !,
    get_hhhh(In, A),
    (   0xD800 =< A,
        A =< 0xDBFF
    ->  get_code(In, 0'\\),
        get_code(In, 0'u),
        get_hhhh(In, B),
        Code is 0x10000+(A-0xD800)*0x400+(B-0xDC00)
    ;   Code is A
    ),
    get_code(In, C).
string_escape(0'U, In, C, Code) :-
    !,
    get_hhhh(In, Code0),
    get_hhhh(In, Code1),
    Code is Code0 << 16 + Code1,
    get_code(In, C).
string_escape(C, _, _, _) :-
    nb_getval(line_number, Ln),
    atom_codes(A, [0'\\, C]),
    throw(illegal_string_escape_sequence(A, line(Ln))).

get_hhhh(In, Code) :-
    get_code(In, C1),
    code_type(C1, xdigit(D1)),
    get_code(In, C2),
    code_type(C2, xdigit(D2)),
    get_code(In, C3),
    code_type(C3, xdigit(D3)),
    get_code(In, C4),
    code_type(C4, xdigit(D4)),
    Code is D1<<12+D2<<8+D3<<4+D4.

language(C0, In, C, [C0|Codes]) :-
    code_type(C0, lower),
    get_code(In, C1),
    lwr_word(C1, In, C2, Codes, Tail),
    sub_langs(C2, In, C, Tail, []).

lwr_word(C0, In, C, [C0|T0], T) :-
    code_type(C0, lower),
    !,
    get_code(In, C1),
    lwr_word(C1, In, C, T0, T).
lwr_word(C, _, C, T, T).

sub_langs(0'-, In, C, [0'-, C1|Codes], T) :-
    get_code(In, C1),
    lwrdig(C1),
    !,
    get_code(In, C2),
    lwrdigs(C2, In, C3, Codes, Tail),
    sub_langs(C3, In, C, Tail, T).
sub_langs(C, _, C, T, T).

lwrdig(C) :-
    code_type(C, lower),
    !.
lwrdig(C) :-
    code_type(C, digit).

lwrdigs(C0, In, C, [C0|T0], T) :-
    lwrdig(C0),
    !,
    get_code(In, C1),
    lwr_word(C1, In, C, T0, T).
lwrdigs(C, _, C, T, T).

iri_chars(0'>, In, C, []) :-
    !,
    get_code(In, C).
iri_chars(0'\\, In, C, D) :-
    !,
    get_code(In, C1),
    iri_escape(C1, In, C2, H),
    \+non_iri_char(H),
    (   current_prolog_flag(windows, true),
        H > 0xFFFF
    ->  E is (H-0x10000)>>10+0xD800,
        F is (H-0x10000) mod 0x400+0xDC00,
        D = [E, F|T]
    ;   D = [H|T]
    ),
    iri_chars(C2, In, C, T).
iri_chars(0'%, In, C, [0'%, C1, C2|T]) :-
    !,
    get_code(In, C1),
    code_type(C1, xdigit(_)),
    get_code(In, C2),
    code_type(C2, xdigit(_)),
    get_code(In, C3),
    iri_chars(C3, In, C, T).
iri_chars(-1, _, _, _) :-
    !,
    fail.
iri_chars(C0, In, C, D) :-
    \+non_iri_char(C0),
    (   current_prolog_flag(windows, true),
        C0 > 0xFFFF
    ->  E is (C0-0x10000)>>10+0xD800,
        F is (C0-0x10000) mod 0x400+0xDC00,
        D = [E, F|T]
    ;   D = [C0|T]
    ),
    get_code(In, C1),
    iri_chars(C1, In, C, T).

iri_escape(0'u, In, C, Code) :-
    !,
    get_hhhh(In, A),
    (   0xD800 =< A,
        A =< 0xDBFF
    ->  get_code(In, 0'\\),
        get_code(In, 0'u),
        get_hhhh(In, B),
        Code is 0x10000+(A-0xD800)*0x400+(B-0xDC00)
    ;   Code is A
    ),
    get_code(In, C).
iri_escape(0'U, In, C, Code) :-
    !,
    get_hhhh(In, Code0),
    get_hhhh(In, Code1),
    Code is Code0 << 16 + Code1,
    get_code(In, C).
iri_escape(C, _, _, _) :-
    nb_getval(line_number, Ln),
    atom_codes(A, [0'\\, C]),
    throw(illegal_iri_escape_sequence(A, line(Ln))).

non_iri_char(C) :-
    0x00 =< C,
    C =< 0x20,
    !.
non_iri_char(0'<).
non_iri_char(0'>).
non_iri_char(0'").
non_iri_char(0'{).
non_iri_char(0'}).
non_iri_char(0'|).
non_iri_char(0'^).
non_iri_char(0'`).
non_iri_char(0'\\).

name(C0, In, C, Atom) :-
    name_start_char(C0),
    get_code(In, C1),
    name_chars(C1, In, C, T),
    atom_codes(Atom, [C0|T]).

name_start_char(C) :-
    pn_chars_base(C),
    !.
name_start_char(0'_).
name_start_char(C) :-
    code_type(C, digit).

name_chars(0'., In, C, [0'.|T]) :-
    peek_code(In, C1),
    pn_chars(C1),
    !,
    get_code(In, C1),
    name_chars(C1, In, C, T).
name_chars(C0, In, C, [C0|T]) :-
    pn_chars(C0),
    !,
    get_code(In, C1),
    name_chars(C1, In, C, T).
name_chars(C, _, C, []).

pn_chars_base(C) :-
    code_type(C, alpha),
    !.
pn_chars_base(C) :-
    0xC0 =< C,
    C =< 0xD6,
    !.
pn_chars_base(C) :-
    0xD8 =< C,
    C =< 0xF6,
    !.
pn_chars_base(C) :-
    0xF8 =< C,
    C =< 0x2FF,
    !.
pn_chars_base(C) :-
    0x370 =< C,
    C =< 0x37D,
    !.
pn_chars_base(C) :-
    0x37F =< C,
    C =< 0x1FFF,
    !.
pn_chars_base(C) :-
    0x200C =< C,
    C =< 0x200D,
    !.
pn_chars_base(C) :-
    0x2070 =< C,
    C =< 0x218F,
    !.
pn_chars_base(C) :-
    0x2C00 =< C,
    C =< 0x2FEF,
    !.
pn_chars_base(C) :-
    0x3001 =< C,
    C =< 0xD7FF,
    !.
pn_chars_base(C) :-
    0xF900 =< C,
    C =< 0xFDCF,
    !.
pn_chars_base(C) :-
    0xFDF0 =< C,
    C =< 0xFFFD,
    !.
pn_chars_base(C) :-
    0x10000 =< C,
    C =< 0xEFFFF.

pn_chars(C) :-
    code_type(C, csym),
    !.
pn_chars(C) :-
    pn_chars_base(C),
    !.
pn_chars(0'-) :-
    !.
pn_chars(0xB7) :-
    !.
pn_chars(C) :-
    0x0300 =< C,
    C =< 0x036F,
    !.
pn_chars(C) :-
    0x203F =< C,
    C =< 0x2040.

local_name(0'\\, In, C, Atom) :-
    !,
    get_code(In, C0),
    reserved_char_escapes(C0),
    get_code(In, C1),
    local_name_chars(C1, In, C, T),
    atom_codes(Atom, [C0|T]).
local_name(0'%, In, C, Atom) :-
    !,
    get_code(In, C0),
    code_type(C0, xdigit(_)),
    get_code(In, C1),
    code_type(C1, xdigit(_)),
    get_code(In, C2),
    local_name_chars(C2, In, C, T),
    atom_codes(Atom, [0'%, C0, C1|T]).
local_name(C0, In, C, Atom) :-
    local_name_start_char(C0),
    get_code(In, C1),
    local_name_chars(C1, In, C, T),
    atom_codes(Atom, [C0|T]).

local_name_chars(0'\\, In, C, [C0|T]) :-
    !,
    get_code(In, C0),
    reserved_char_escapes(C0),
    get_code(In, C1),
    local_name_chars(C1, In, C, T).
local_name_chars(0'%, In, C, [0'%, C0, C1|T]) :-
    !,
    get_code(In, C0),
    code_type(C0, xdigit(_)),
    get_code(In, C1),
    code_type(C1, xdigit(_)),
    get_code(In, C2),
    local_name_chars(C2, In, C, T).
local_name_chars(0'., In, C, [0'.|T]) :-
    peek_code(In, C1),
    (   local_name_char(C1)
    ;   C1 = 0'.
    ),
    !,
    get_code(In, C1),
    local_name_chars(C1, In, C, T).
local_name_chars(C0, In, C, [C0|T]) :-
    local_name_char(C0),
    !,
    get_code(In, C1),
    local_name_chars(C1, In, C, T).
local_name_chars(C, _, C, []).

local_name_start_char(C) :-
    name_start_char(C),
    !.
local_name_start_char(0':).
local_name_start_char(0'%).
local_name_start_char(0'\\).

local_name_char(C) :-
    pn_chars(C),
    !.
local_name_char(0':).
local_name_char(0'%).
local_name_char(0'\\).

reserved_char_escapes(0'~).
reserved_char_escapes(0'.).
reserved_char_escapes(0'-).
reserved_char_escapes(0'!).
reserved_char_escapes(0'$).
reserved_char_escapes(0'&).
reserved_char_escapes(0'').
reserved_char_escapes(0'().
reserved_char_escapes(0')).
reserved_char_escapes(0'*).
reserved_char_escapes(0'+).
reserved_char_escapes(0',).
reserved_char_escapes(0';).
reserved_char_escapes(0'=).
reserved_char_escapes(0'/).
reserved_char_escapes(0'?).
reserved_char_escapes(0'#).
reserved_char_escapes(0'@).
reserved_char_escapes(0'%).
reserved_char_escapes(0'_).

punctuation(0'(, '(').
punctuation(0'), ')').
punctuation(0'[, '[').
punctuation(0'], ']').
punctuation(0',, ',').
punctuation(0':, ':').
punctuation(0';, ';').
punctuation(0'{, '{').
punctuation(0'}, '}').
punctuation(0'?, '?').
punctuation(0'!, '!').
punctuation(0'^, '^').
punctuation(0'=, '=').
punctuation(0'<, '<').
punctuation(0'>, '>').
punctuation(0'$, '$').

skip_line(-1, _, -1) :-
    !.
skip_line(0xA, In, C) :-
    !,
    cnt(line_number),
    get_code(In, C).
skip_line(0xD, In, C) :-
    !,
    get_code(In, C).
skip_line(_, In, C) :-
    get_code(In, C1),
    skip_line(C1, In, C).

white_space(0x9).
white_space(0xA) :-
    cnt(line_number).
white_space(0xD).
white_space(0x20).

%
% Reasoning output
%

w0([]) :-
    !.
w0(['--image', _|A]) :-
    !,
    w0(A).
w0([A|B]) :-
    (   \+sub_atom(A, 1, _, _, '"'),
        sub_atom(A, _, 1, _, ' '),
        \+sub_atom(A, _, _, 1, '"')
    ->  format(' "~w"', [A])
    ;   format(' ~w', [A])
    ),
    w0(B).

w1([]) :-
    !.
w1([A|B]) :-
    (   \+sub_atom(A, 1, _, _, '"'),
        sub_atom(A, _, 1, _, ' '),
        \+sub_atom(A, _, _, 1, '"')
    ->  format(' "~w"', [A])
    ;   format(' ~w', [A])
    ),
    w1(B).

wh :-
    (   keep_skolem(_)
    ->  nb_getval(var_ns, Sns),
        put_pfx('skolem', Sns)
    ;   true
    ),
    (   flag('no-qnames')
    ->  true
    ;   nb_setval(wpfx, false),
        forall(
            (   pfx(A, B),
                \+wpfx(A)
            ),
            (   format('@prefix ~w ~w.~n', [A, B]),
                assertz(wpfx(A)),
                nb_setval(wpfx, true)
            )
        ),
        (   \+ (flag('pass-only-new'), flag(nope)),
            nb_getval(wpfx, true)
        ->  nl
        ;   true
        )
    ).

w2 :-
    (   flag('n3p-output')
    ->  true
    ;   wh,
        nl
    ),
    forall(
        pass_only_new(Zn),
        (   indent,
            relabel(Zn, Zr),
            (   flag('n3p-output')
            ->  makeblank(Zr, Zs),
                writeq(Zs)
            ;   wt(Zr)
            ),
            ws(Zr),
            write('.'),
            nl,
            (   (   Zr = '<http://www.w3.org/2000/10/swap/log#implies>'(_, _)
                )
            ->  nl
            ;   true
            ),
            cnt(output_statements)
        )
    ).

w3 :-
    (   flag('n3p-output')
    ->  true
    ;   wh
    ),
    nb_setval(fdepth, 0),
    nb_setval(pdepth, 0),
    nb_setval(cdepth, 0),
    flag(nope),
    !,
    (   query(Q, A),
        (   Q = \+(R)
        ->  \+catch(call(R), _, fail)
        ;   catch(call(Q), _, fail)
        ),
        nb_getval(wn, W),
        labelvars(A, W, N, some),
        nb_setval(wn, N),
        relabel(A, B),
        indent,
        (   flag('n3p-output')
        ->  makeblank(B, Ba),
            exo_pred(Ba, Bb),
            writeq(Bb)
        ;   wt(B)
        ),
        ws(B),
        (   (   B = graph(_, _)
            ;   B = exopred(graph, _, _)
            )
        ->  true
        ;   write('.')
        ),
        nl,
        (   A = (_, _),
            conj_list(A, L)
        ->  length(L, I),
            cnt(output_statements, I)
        ;   cnt(output_statements)
        ),
        fail
    ;   true
    ),
    (   answer(B1, B2, B3),
        relabel([B1, B2, B3], [C1, C2, C3]),
        djiti_answer(answer(C), answer(C1, C2, C3)),
        indent,
        (   flag('n3p-output')
        ->  makeblank(C, Ca),
            exo_pred(Ca, Cb),
            writeq(Cb)
        ;   wt(C)
        ),
        ws(C),
        (   (   C = graph(_, _)
            ;   C = exopred(graph, _, _)
            )
        ->  true
        ;   write('.')
        ),
        nl,
        cnt(output_statements),
        fail
    ;   true
    ).
w3 :-
    (   prfstep(answer(_, _, _), _, _, _, _, _, _),
        !,
        nb_setval(empty_gives, false),
        indent,
        nb_getval(var_ns, Sns),
        atomic_list_concat(['<', Sns, 'proof', '>'], Sk),
        wp(Sk),
        write(' '),
        wp('<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>'),
        write(' '),
        wp('<http://www.w3.org/2000/10/swap/reason#Proof>'),
        write(', '),
        wp('<http://www.w3.org/2000/10/swap/reason#Conjunction>'),
        write(';'),
        indentation(4),
        nl,
        indent,
        (   prfstep(answer(_, _, _), B, Pnd, Cn, R, _, A),
            R =.. [P, S, O1],
            djiti_answer(answer(O), O1),
            Rule =.. [P, S, O],
            djiti_answer(answer(C), Cn),
            nb_setval(empty_gives, C),
            \+got_wi(A, B, Pnd, C, Rule),
            assertz(got_wi(A, B, Pnd, C, Rule)),
            wp('<http://www.w3.org/2000/10/swap/reason#component>'),
            write(' '),
            wi(A, B, C, Rule),
            write(';'),
            nl,
            indent,
            fail
        ;   retractall(got_wi(_, _, _, _, _))
        ),
        wp('<http://www.w3.org/2000/10/swap/reason#gives>'),
        (   nb_getval(empty_gives, true)
        ->  write(' true.')
        ;   write(' {'),
            indentation(4),
            (   prfstep(answer(B1, B2, B3), _, _, _, _, _, _),
                relabel([B1, B2, B3], [C1, C2, C3]),
                djiti_answer(answer(C), answer(C1, C2, C3)),
                nl,
                indent,
                getvars(C, D),
                (   C = '<http://www.w3.org/2000/10/swap/log#implies>'(_, _)
                ->  Q = allv
                ;   Q = some
                ),
                wq(D, Q),
                wt(C),
                ws(C),
                write('.'),
                cnt(output_statements),
                fail
            ;   true
            ),
            indentation(-4),
            nl,
            indent,
            write('}.')
        ),
        indentation(-4),
        nl,
        nl
    ;   true
    ),
    (   nb_getval(lemma_count, Lco),
        nb_getval(lemma_cursor, Lcu),
        Lcu < Lco
    ->  repeat,
        cnt(lemma_cursor),
        nb_getval(lemma_cursor, Cursor),
        lemma(Cursor, Ai, Bi, Ci, _, Di),
        indent,
        wj(Cursor, Ai, Bi, Ci, Di),
        nl,
        nl,
        nb_getval(lemma_count, Cnt),
        Cursor = Cnt,
        !
    ;   true
    ).

wi('<>', _, rule(_, _, A), _) :-    % wi(Source, Premise, Conclusion, Rule)
    !,
    assertz(nonl),
    wr(A),
    retract(nonl).
wi(A, B, C, Rule) :-
    term_index(B-C, Ind),
    (   lemma(Cnt, A, B, C, Ind, Rule)
    ->  true
    ;   cnt(lemma_count),
        nb_getval(lemma_count, Cnt),
        assertz(lemma(Cnt, A, B, C, Ind, Rule))
    ),
    nb_getval(var_ns, Sns),
    atomic_list_concat(['<', Sns, 'lemma', Cnt, '>'], Sk),
    wp(Sk).

wj(Cnt, A, true, C, Rule) :-        % wj(Count, Source, Premise, Conclusion, Rule)
    var(Rule),
    C \= '<http://www.w3.org/2000/10/swap/log#implies>'(_, _),
    !,
    nb_getval(var_ns, Sns),
    atomic_list_concat(['<', Sns, 'lemma', Cnt, '>'], Sk),
    wp(Sk),
    write(' '),
    wp('<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>'),
    write(' '),
    wp('<http://www.w3.org/2000/10/swap/reason#Extraction>'),
    writeln(';'),
    indentation(4),
    indent,
    wp('<http://www.w3.org/2000/10/swap/reason#gives>'),
    (   C = true
    ->  write(' true;')
    ;   write(' {'),
        nl,
        indentation(4),
        indent,
        (   C = rule(PVars, EVars, Rule)
        ->  wq(PVars, allv),
            wq(EVars, some),
            wt(Rule)
        ;   labelvars([A, C], 0, _, avar),
            getvars(C, D),
            wq(D, some),
            wt(C)
        ),
        ws(C),
        write('.'),
        nl,
        indentation(-4),
        indent,
        write('};')
    ),
    nl,
    indent,
    wp('<http://www.w3.org/2000/10/swap/reason#because>'),
    write(' [ '),
    wp('<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>'),
    write(' '),
    wp('<http://www.w3.org/2000/10/swap/reason#Parsing>'),
    write('; '),
    wp('<http://www.w3.org/2000/10/swap/reason#source>'),
    write(' '),
    (   C = rule(_, _, Rl),
        Rl =.. [P, S, O],
        '<http://www.w3.org/2000/10/swap/reason#source>'(triple(S, P, O), Src)
    ->  wt(Src)
    ;   (   C =.. [P, S, O],
            '<http://www.w3.org/2000/10/swap/reason#source>'(triple(S, P, O), Src)
        ->  wt(Src)
        ;   wt(A)
        )
    ),
    write('].'),
    indentation(-4).
wj(Cnt, A, B, C, Rule) :-
    nb_getval(var_ns, Sns),
    atomic_list_concat(['<', Sns, 'lemma', Cnt, '>'], Sk),
    wp(Sk),
    write(' '),
    wp('<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>'),
    write(' '),
    wp('<http://www.w3.org/2000/10/swap/reason#Inference>'),
    writeln(';'),
    indentation(4),
    indent,
    wp('<http://www.w3.org/2000/10/swap/reason#gives>'),
    (   C = true
    ->  write(' true;')
    ;   write(' {'),
        nl,
        Rule = '<http://www.w3.org/2000/10/swap/log#implies>'(Prem, Conc),
        nb_getval(wn, W),
        labelvars([A, B, C], W, N, avar),
        nb_setval(wn, N),
        unifiable(Prem, B, Bs),
        (   unifiable(Conc, C, Cs)
        ->  true
        ;   Cs = []
        ),
        append(Bs, Cs, Ds),
        sort(Ds, Bindings),
        term_variables(Prem, PVars),
        term_variables(Conc, CVars),
        labelvars([Rule, PVars, CVars], 0, _, avar),
        findall(V,
            (   member(V, CVars),
                \+member(V, PVars)
            ),
            EVars
        ),
        getvars(C, D),
        (   C = '<http://www.w3.org/2000/10/swap/log#implies>'(_, _)
        ->  Q = allv
        ;   Q = some
        ),
        indentation(4),
        indent,
        wq(D, Q),
        wt(C),
        ws(C),
        write('.'),
        nl,
        indentation(-4),
        indent,
        write('};')
    ),
    nl,
    indent,
    wp('<http://www.w3.org/2000/10/swap/reason#evidence>'),
    write(' ('),
    indentation(4),
    wr(B),
    indentation(-4),
    nl,
    indent,
    write(');'),
    retractall(got_wi(_, _, _, _, _)),
    nl,
    indent,
    wb(Bindings),
    wp('<http://www.w3.org/2000/10/swap/reason#rule>'),
    write(' '),
    wi(A, true, rule(PVars, EVars, Rule), _),
    write('.'),
    indentation(-4).

wr(exopred(P, S, O)) :-             % write reason
    atom(P),
    !,
    U =.. [P, S, O],
    wr(U).
wr((X, Y)) :-
    !,
    wr(X),
    wr(Y).
wr(Z) :-
    prfstep(Z, Y, _, Q, Rule, _, X),
    !,
    (   nonl
    ->  true
    ;   nl,
        indent
    ),
    wi(X, Y, Q, Rule).
wr(Y) :-
    (   nonl
    ->  true
    ;   nl,
        indent
    ),
    write('[ '),
    wp('<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>'),
    write(' '),
    wp('<http://www.w3.org/2000/10/swap/reason#Fact>'),
    write('; '),
    wp('<http://www.w3.org/2000/10/swap/reason#gives>'),
    write(' '),
    (   Y = true
    ->  wt(Y)
    ;   write('{'),
        labelvars(Y, 0, _, avar),
        getvars(Y, Z),
        wq(Z, some),
        X = Y,
        wt(X),
        write('}')
    ),
    write(']').

wt(X) :-
    var(X),
    !,
    write('?'),
    write(X).
wt(X) :-
    functor(X, _, A),
    (   A = 0,
        !,
        wt0(X)
    ;   A = 1,
        !,
        wt1(X)
    ;   A = 2,
        !,
        wt2(X)
    ;   wtn(X)
    ).

wt0(!) :-
    !,
    (   flag(see)
    ->  write('_:true')
    ;   write('true ')
    ),
    wp('<http://www.w3.org/2000/10/swap/log#callWithCut>'),
    write(' true').
wt0(:-) :-
    !,
    wp('<http://www.w3.org/2000/10/swap/log#isImpliedBy>').
wt0(fail) :-
    !,
    write('("fail") '),
    wp('<http://eulersharp.sourceforge.net/2003/03swap/log-rules#derive>'),
    write(' true').
wt0([]) :-
    !,
    (   flag('rdf-list-output')
    ->  wt0('<http://www.w3.org/1999/02/22-rdf-syntax-ns#nil>')
    ;   write('()')
    ).
wt0(X) :-
    number(X),
    !,
    (   flag('no-numerals')
    ->  dtlit([U, V], X),
        dtlit([U, V], W),
        wt(W)
    ;   write(X)
    ).
wt0(X) :-
    atom(X),
    atom_concat(some, Y, X),
    !,
    (   \+flag('no-qvars')
    ->  (   rule_uvar(L),
            (   ncllit
            ->  (   memberchk(X, L)
                ->  true
                ;   retract(rule_uvar(L)),
                    assertz(rule_uvar([X|L]))
                )
            ;   memberchk(X, L)
            )
        ->  write('?U_')
        ;   write('_:sk_')
        ),
        write(Y)
    ;   atomic_list_concat(['<http://www.w3.org/2000/10/swap/var#some_', Y, '>'], Z),
        wt0(Z)
    ).
wt0(X) :-
    atom(X),
    atom_concat(allv, Y, X),
    !,
    (   \+flag('no-qvars'),
        \+flag('pass-all-ground')
    ->  (   flag(see)
        ->  write('var:U_')
        ;   write('?U_')
        ),
        write(Y)
    ;   atomic_list_concat(['<http://www.w3.org/2000/10/swap/var#all_', Y, '>'], Z),
        wt0(Z)
    ).
wt0(X) :-
    atom(X),
    atom_concat(avar, Y, X),
    !,
    atomic_list_concat(['<http://www.w3.org/2000/10/swap/var#x_', Y, '>'], Z),
    wt0(Z).
wt0(X) :-
    flag(nope),
    \+flag('pass-all-ground'),
    \+keep_skolem(X),
    nb_getval(var_ns, Sns),
    atom(X),
    sub_atom(X, 1, I, _, Sns),
    J is I+1,
    sub_atom(X, J, _, 1, Y),
    (   getlist(X, M)
    ->  wt(M)
    ;   (   rule_uvar(L),
            (   ncllit
            ->  (   memberchk(Y, L)
                ->  true
                ;   retract(rule_uvar(L)),
                    assertz(rule_uvar([Y|L]))
                )
            ;   memberchk(Y, L)
            )
        ->  (   (   sub_atom(Y, 0, 2, _, 'e_')
                ;   sub_atom(Y, 0, 3, _, 'bn_')
                )
            ->  write('_:')
            ;   sub_atom(Y, 0, 2, _, Z),
                memberchk(Z, ['x_', 't_']),
                write('?')
            )
        ;   (   \+flag('no-qvars')
            ->  true
            ;   flag('quantify', Prefix),
                sub_atom(X, 1, _, _, Prefix)
            ),
            write('_:')
        ),
        write(Y),
        (   sub_atom(Y, 0, 2, _, 'x_')
        ->  write('_'),
            nb_getval(rn, N),
            write(N)
        ;   true
        )
    ),
    !.
wt0(X) :-
    flag('quantify', Prefix),
    flag(nope),
    atom(X),
    sub_atom(X, 1, _, _, Prefix),
    !,
    (   getlist(X, M)
    ->  wt(M)
    ;   '<http://eulersharp.sourceforge.net/2003/03swap/log-rules#tuple>'(Y, ['quantify', Prefix, X]),
        wt0(Y)
    ).
wt0(X) :-
    (   wtcache(X, W)
    ->  true
    ;   (   \+flag('no-qnames'),
            atom(X),
            (   sub_atom(X, I, 1, J, '#')
            ->  J > 1,
                sub_atom(X, 0, I, _, C),
                atom_concat(C, '#>', D)
            ;   (   sub_atom_last(X, I, 1, J, '/')
                ->  J > 1,
                    sub_atom(X, 0, I, _, C),
                    atom_concat(C, '/>', D)
                ;   (   sub_atom_last(X, I, 1, J, ':')
                    ->  sub_atom(X, 0, I, _, C),
                        atom_concat(C, ':>', D)
                    ;   J = 1,
                        D = X
                    )
                )
            ),
            pfx(E, D),
            (   apfx(E, D)
            ->  true
            ;   assertz(apfx(E, D))
            ),
            K is J-1,
            sub_atom(X, _, K, 1, F)
        ->  atom_concat(E, F, W),
            assertz(wtcache(X, W))
        ;   (   \+flag(strings),
                atom(X),
                \+ (sub_atom(X, 0, 1, _, '<'), sub_atom(X, _, 1, 0, '>')),
                \+sub_atom(X, 0, 2, _, '_:'),
                X \= true,
                X \= false
            ->  W = literal(X, type('<http://www.w3.org/2001/XMLSchema#string>'))
            ;   W = X
            )
        )
    ),
    (   W = literal(X, type('<http://www.w3.org/2001/XMLSchema#string>'))
    ->  wt2(W)
    ;   (   current_prolog_flag(windows, true)
        ->  atom_codes(W, U),
            escape_unicode(U, V),
            atom_codes(Z, V)
        ;   Z = W
        ),
        (   atom(Z)
        ->  write(Z)
        ;   '<http://eulersharp.sourceforge.net/2003/03swap/log-rules#tuple>'(A, [blob, Z]),
            wt(A)
        )
    ).

wt1(set(X)) :-
    !,
    write('($'),
    wl(X),
    write(' $)').
wt1('$VAR'(X)) :-
    !,
    write('?V'),
    write(X).
wt1(X) :-
    X =.. [B|C],
    (   atom(B),
        \+ (sub_atom(B, 0, 1, _, '<'), sub_atom(B, _, 1, 0, '>'))
    ->  write('"'),
        writeq(X),
        write('"')
    ;   wt(C),
        write(' '),
        wp(B),
        write(' true')
    ).

wt2((X, Y)) :-
    !,
    (   atomic(X),
        X \= '!',
        X \= true
    ->  wt2([X, Y]),
        write(' '),
        wt0('<http://www.w3.org/2000/10/swap/log#conjunction>'),
        write(' true')
    ;   wt(X),
        ws(X),
        write('.'),
        (   flag(strings)
        ->  write(' ')
        ;   (   flag('no-beautified-output')
            ->  write(' ')
            ;   nl,
                indent
            )
        ),
        wt(Y)
    ).
wt2([X|Y]) :-
    !,
    (   flag('rdf-list-output')
    ->  write('['),
        nl,
        indentation(4),
        indent,
        wt0('<http://www.w3.org/1999/02/22-rdf-syntax-ns#first>'),
        write(' '),
        wg(X),
        write('; '),
        nl,
        indent,
        wt0('<http://www.w3.org/1999/02/22-rdf-syntax-ns#rest>'),
        write(' '),
        wt(Y),
        nl,
        indentation(-4),
        indent,
        write(']')
    ;   write('('),
        wg(X),
        wl(Y),
        write(')')
    ).
wt2(literal(X, lang(Y))) :-
    !,
    write('"'),
    (   current_prolog_flag(windows, true)
    ->  atom_codes(X, U),
        escape_unicode(U, V),
        atom_codes(Z, V)
    ;   Z = X
    ),
    write(Z),
    write('"@'),
    write(Y).
wt2(literal(X, type('<http://www.w3.org/2001/XMLSchema#string>'))) :-
    !,
    write('"'),
    (   current_prolog_flag(windows, true)
    ->  atom_codes(X, U),
        escape_unicode(U, V),
        atom_codes(Z, V)
    ;   Z = X
    ),
    write(Z),
    write('"').
wt2(literal(X, type(Y))) :-
    !,
    write('"'),
    (   current_prolog_flag(windows, true)
    ->  atom_codes(X, U),
        escape_unicode(U, V),
        atom_codes(Z, V)
    ;   Z = X
    ),
    write(Z),
    write('"^^'),
    wt(Y).
wt2(rdiv(X, Y)) :-
    number_codes(Y, [0'1|Z]),
    lzero(Z, Z),
    !,
    (   Z = []
    ->  F = '~d.0'
    ;   length(Z, N),
        number_codes(X, U),
        (   length(U, N)
        ->  F = '0.~d'
        ;   atomic_list_concat(['~', N, 'd'], F)
        )
    ),
    (   flag('no-numerals')
    ->  write('"')
    ;   true
    ),
    format(F, [X]),
    (   flag('no-numerals')
    ->  write('"^^'),
        wt0('<http://www.w3.org/2001/XMLSchema#decimal>')
    ;   true
    ).
wt2(rdiv(X, Y)) :-
    !,
    (   flag('no-numerals')
    ->  write('"')
    ;   true
    ),
    format('~g', [rdiv(X, Y)]),
    (   flag('no-numerals')
    ->  write('"^^'),
        wt0('<http://www.w3.org/2001/XMLSchema#decimal>')
    ;   true
    ).
wt2('<http://eulersharp.sourceforge.net/2003/03swap/log-rules#biconditional>'([X|Y], Z)) :-
    flag(nope),
    !,
    '<http://www.w3.org/2000/10/swap/log#conjunction>'(Y, U),
    write('{'),
    wt(U),
    write('. _: '),
    wp('<http://eulersharp.sourceforge.net/2003/03swap/log-rules#true>'),
    write(' '),
    wt(Z),
    write('} '),
    wp('<http://www.w3.org/2000/10/swap/log#implies>'),
    write(' {'),
    wt(X),
    write('}').
wt2('<http://eulersharp.sourceforge.net/2003/03swap/log-rules#conditional>'([X|Y], Z)) :-
    flag(nope),
    !,
    '<http://www.w3.org/2000/10/swap/log#conjunction>'(Y, U),
    write('{'),
    wt(U),
    write('. _: '),
    wp('<http://eulersharp.sourceforge.net/2003/03swap/log-rules#true>'),
    write(' '),
    wt(Z),
    write('} '),
    wp('<http://www.w3.org/2000/10/swap/log#implies>'),
    write(' {'),
    wt(X),
    write('}').
wt2('<http://www.w3.org/2000/10/swap/log#implies>'(X, Y)) :-
    (   flag(nope)
    ->  U = X
    ;   (   X = when(A, B)
        ->  conj_append(B, istep(_, _, _, _), C),
            U = when(A, C)
        ;   conj_append(X, istep(_, _, _, _), U)
        )
    ),
    (   flag('rule-histogram')
    ->  (   U = when(D, E)
        ->  conj_append(E, pstep(_), F),
            Z = when(D, F)
        ;   conj_append(U, pstep(_), Z)
        )
    ;   Z = U
    ),
    (   rule_uvar(R)
    ->  true
    ;   R = [],
        cnt(rn)
    ),
    (   nb_getval(pdepth, 0),
        nb_getval(cdepth, 0)
    ->  assertz(rule_uvar(R))
    ;   true
    ),
    (   catch(clause(Y, Z), _, fail)
    ->  (   nb_getval(fdepth, 0)
        ->  assertz(ncllit)
        ;   true
        ),
        wg(Y),
        write(' <= '),
        wg(X),
        (   nb_getval(fdepth, 0)
        ->  retract(ncllit)
        ;   true
        )
    ;   (   clause('<http://www.w3.org/2000/10/swap/log#implies>'(X, Y, _, _, _, _), true)
        ->  wg(X),
            write(' => '),
            wg(Y)
        ;   (   nb_getval(fdepth, 0)
            ->  assertz(ncllit)
            ;   true
            ),
            (   \+atom(X)
            ->  nb_getval(pdepth, PD),
                PD1 is PD+1,
                nb_setval(pdepth, PD1)
            ;   true
            ),
            wg(X),
            (   \+atom(X)
            ->  nb_setval(pdepth, PD)
            ;   true
            ),
            (   nb_getval(fdepth, 0)
            ->  retract(ncllit)
            ;   true
            ),
            write(' => '),
            (   \+atom(Y)
            ->  nb_getval(cdepth, CD),
                CD1 is CD+1,
                nb_setval(cdepth, CD1)
            ;   true
            ),
            wg(Y),
            (   \+atom(Y)
            ->  nb_setval(cdepth, CD)
            ;   true
            )
        )
    ),
    (   nb_getval(pdepth, 0),
        nb_getval(cdepth, 0)
    ->  retract(rule_uvar(_))
    ;   true
    ),
    !.
wt2(':-'(X, Y)) :-
    (   rule_uvar(R)
    ->  true
    ;   R = [],
        cnt(rn)
    ),
    (   nb_getval(fdepth, 0)
    ->  assertz(ncllit)
    ;   true
    ),
    assertz(rule_uvar(R)),
    wg(X),
    write(' <= '),
    wg(Y),
    retract(rule_uvar(U)),
    (   U \= [],
        retract(rule_uvar(V)),
        append(U, V, W)
    ->  assertz(rule_uvar(W))
    ;   true
    ),
    (   nb_getval(fdepth, 0)
    ->  retract(ncllit)
    ;   true
    ),
    !.
wt2(quad(triple(S, P, O), G)) :-
    !,
    wg(S),
    write(' '),
    wt0(P),
    write(' '),
    wg(O),
    write(' '),
    wg(G).
wt2(graph(X, Y)) :-
    !,
    wp(X),
    write(' '),
    nb_setval(keep_ng, false),
    retractall(keep_ng(graph(X, Y))),
    wg(Y).
wt2(is(O, T)) :-
    !,
    (   number(T),
        T < 0
    ->  P = -,
        Q is -T,
        S = [Q]
    ;   T =.. [P|S]
    ),
    wg(S),
    write(' '),
    wp(P),
    write(' '),
    wg(O).
wt2(X-Y) :-
    !,
    term_to_atom(X-Y, Z),
    wt0(Z).
wt2(X) :-
    X =.. [P, S, O],
    (   atom(P),
        \+ (sub_atom(P, 0, 1, _, '<'), sub_atom(P, _, 1, 0, '>')),
        \+sub_atom(P, 0, 4, _, avar),
        \+sub_atom(P, 0, 4, _, allv),
        \+sub_atom(P, 0, 4, _, some),
        \+sub_atom(P, 0, 2, _, '_:'),
        P \= true,
        P \= false
    ->  write('"'),
        writeq(X),
        write('"')
    ;   wg(S),
        write(' '),
        wp(P),
        write(' '),
        wg(O)
    ).

wtn(exopred(P, S, O)) :-
    !,
    (   atom(P)
    ->  X =.. [P, S, O],
        wt2(X)
    ;   wg(S),
        write(' '),
        wg(P),
        write(' '),
        wg(O)
    ).
wtn(triple(S, P, O)) :-
    !,
    write('<< '),
    wg(S),
    write(' '),
    wp(P),
    write(' '),
    wg(O),
    write(' >>').
wtn(X) :-
    X =.. [B|C],
    (   atom(B),
        \+ (sub_atom(B, 0, 1, _, '<'), sub_atom(B, _, 1, 0, '>'))
    ->  write('"'),
        writeq(X),
        write('"')
    ;   wt(C),
        write(' '),
        wp(B),
        write(' true')
    ).

wg(X) :-
    var(X),
    !,
    write('?'),
    write(X).
wg(X) :-
    functor(X, F, A),
    (   (   F = exopred,
            !
        ;   F = ',',
            F \= true,
            F \= false,
            F \= '-',
            F \= /,
            !
        ;   A = 2,
            F \= '.',
            F \= '[|]',
            F \= ':',
            F \= literal,
            F \= rdiv,
            (   sub_atom(F, 0, 1, _, '<'),
                sub_atom(F, _, 1, 0, '>')
            ;   sub_atom(F, 0, 2, _, '_:')
            ;   F = ':-'
            )
        )
    ->  (   flag(see),
            nb_getval(keep_ng, true)
        ->  (   graph(N, X)
            ->  true
            ;   gensym('gn_', Y),
                nb_getval(var_ns, Sns),
                atomic_list_concat(['<', Sns, Y, '>'], N),
                assertz(graph(N, X))
            ),
            (   \+keep_ng(graph(N, X))
            ->  assertz(keep_ng(graph(N, X)))
            ;   true
            ),
            wt(N)
        ;   nb_setval(keep_ng, true),
            write('{'),
            indentation(4),
            (   flag(strings)
            ->  true
            ;   (   flag('no-beautified-output')
                ->  true
                ;   nl,
                    indent
                )
            ),
            nb_getval(fdepth, D),
            E is D+1,
            nb_setval(fdepth, E),
            wt(X),
            nb_setval(fdepth, D),
            indentation(-4),
            (   flag(strings)
            ->  true
            ;   (   flag('no-beautified-output')
                ->  true
                ;   write('.'),
                    nl,
                    indent
                )
            ),
            write('}')
        )
    ;   wt(X)
    ).

wp('<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>') :-
    \+flag('no-qnames'),
    !,
    write('a').
wp('<http://www.w3.org/2000/10/swap/log#implies>') :-
    \+flag('no-qnames'),
    !,
    write('=>').
wp(':-') :-
    \+flag('no-qnames'),
    !,
    write('<=').
wp(X) :-
    wg(X).

wk([]) :-
    !.
wk([X|Y]) :-
    write(', '),
    wt(X),
    wk(Y).

wl([]) :-
    !.
wl([X|Y]) :-
    write(' '),
    wg(X),
    wl(Y).

wq([], _) :-
    !.
wq([X|Y], allv) :-
    !,
    write('@forAll '),
    wt(X),
    wk(Y),
    write('. ').
wq([X|Y], some) :-
    (   \+flag('no-qvars')
    ->  write('@forSome '),
        wt(X),
        wk(Y),
        write('. ')
    ;   true
    ).

wb([]) :-
    !.
wb([X = Y|Z]) :-
    wp('<http://www.w3.org/2000/10/swap/reason#binding>'),
    write(' [ '),
    wp('<http://www.w3.org/2000/10/swap/reason#variable>'),
    write(' '),
    wv(X),
    write('; '),
    wp('<http://www.w3.org/2000/10/swap/reason#boundTo>'),
    write(' '),
    wv(Y),
    write('];'),
    nl,
    indent,
    wb(Z).

wv(X) :-
    atom(X),
    atom_concat(avar, Y, X),
    !,
    write('[ '),
    wp('<http://www.w3.org/2004/06/rei#uri>'),
    write(' "http://www.w3.org/2000/10/swap/var#x_'),
    write(Y),
    write('"]').
wv(X) :-
    atom(X),
    atom_concat(some, Y, X),
    !,
    write('[ '),
    wp('<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>'),
    write(' '),
    wp('<http://www.w3.org/2000/10/swap/reason#Existential>'),
    write('; '),
    wp('<http://www.w3.org/2004/06/rei#nodeId>'),
    write(' "_:sk_'),
    write(Y),
    write('"]').
wv(X) :-
    atom(X),
    nb_getval(var_ns, Sns),
    sub_atom(X, 1, I, _, Sns),
    !,
    write('[ '),
    wp('<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>'),
    write(' '),
    wp('<http://www.w3.org/2000/10/swap/reason#Existential>'),
    write('; '),
    wp('<http://www.w3.org/2004/06/rei#nodeId>'),
    write(' "'),
    write(Sns),
    J is I+1,
    sub_atom(X, J, _, 1, Q),
    write(Q),
    write('"]').
wv(X) :-
    atom(X),
    sub_atom(X, 1, _, 1, U),
    atomic_list_concat(['<', U, '>'], X),
    !,
    write('[ '),
    wp('<http://www.w3.org/2004/06/rei#uri>'),
    write(' "'),
    write(U),
    write('"]').
wv(X) :-
    wg(X).

ws((X, Y)) :-
    !,
    conj_list((X, Y), Z),
    last(Z, U),
    ws(U).
ws(X) :-
    X =.. Y,
    last(Y, Z),
    (   \+number(Z),
        Z \= rdiv(_, _)
    ->  true
    ;   (   \+flag('n3p-output')
        ->  write(' ')
        ;   true
        )
    ).

wst :-
    findall([Key, Str],
        (   '<http://www.w3.org/2000/10/swap/log#outputString>'(Key, Str)
        ;   answer(A1, A2, A3),
            djiti_answer(answer('<http://www.w3.org/2000/10/swap/log#outputString>'(Key, Str)), answer(A1, A2, A3))
        ),
        KS
    ),
    sort(KS, KT),
    forall(
        (   member([_, MT], KT),
            getcodes(MT, LT)
        ),
        (   escape_string(NT, LT),
            atom_codes(ST, NT),
            wt(ST)
        )
    ),
    (   catch(nb_getval(csv_header, Header), _, Header = []),
        catch(nb_getval(csv_header_strings, Headers), _, Headers = []),
        wct(Headers, Header),
        length(Header, Headerl),
        query(Where, '<http://eulersharp.sourceforge.net/2003/03swap/log-rules#csvTuple>'(_, Select)),
        catch(call(Where), _, fail),
        \+got_cs(Select),
        assertz(got_cs(Select)),
        write('\r\n'),
        wct(Select, Header),
        cnt(output_statements, Headerl),
        cnt(answer_count),
        nb_getval(answer_count, AnswerCount),
        (   flag('limited-answer', AnswerLimit),
            AnswerCount >= AnswerLimit
        ->  true
        ;   fail
        )
    ;   true
    ),
    nl.

wct([], []) :-
    !.
wct([A], [C]) :-
    !,
    wcf(A, C).
wct([A|B], [C|D]) :-
    wcf(A, C),
    (   flag('csv-separator', S)
    ->  true
    ;   S = ','
    ),
    write(S),
    wct(B, D).

wcf(A, _) :-
    var(A),
    !.
wcf(rdiv(X, Y), _) :-
    number_codes(Y, [0'1|Z]),
    lzero(Z, Z),
    !,
    (   Z = []
    ->  F = '~d.0'
    ;   length(Z, N),
        number_codes(X, U),
        (   length(U, N)
        ->  F = '0.~d'
        ;   atomic_list_concat(['~', N, 'd'], F)
        )
    ),
    format(F, [X]).
wcf(literal(A, B), _) :-
    !,
    atom_codes(A, C),
    subst([[[0'\\, 0'"], [0'", 0'"]]], C, E),
    atom_codes(F, E),
    (   B \= type('<http://www.w3.org/2001/XMLSchema#dateTime>'),
        B \= type('<http://www.w3.org/2001/XMLSchema#date>'),
        B \= type('<http://www.w3.org/2001/XMLSchema#time>'),
        B \= type('<http://www.w3.org/2001/XMLSchema#duration>'),
        B \= type('<http://www.w3.org/2001/XMLSchema#yearMonthDuration>'),
        B \= type('<http://www.w3.org/2001/XMLSchema#dayTimeDuration>')
    ->  write('"'),
        write(F),
        write('"')
    ;   write(F)
    ).
wcf(A, _) :-
    atom(A),
    nb_getval(var_ns, Sns),
    sub_atom(A, 1, I, _, Sns),
    !,
    J is I+1,
    sub_atom(A, J, _, 1, B),
    write('_:'),
    write(B).
wcf(A, _) :-
    atom(A),
    flag('quantify', Prefix),
    sub_atom(A, 1, _, _, Prefix),
    !,
    '<http://eulersharp.sourceforge.net/2003/03swap/log-rules#tuple>'(B, ['quantify', Prefix, A]),
    wt0(B).
wcf(A, B) :-
    atom(A),
    relabel(A, C),
    sub_atom(C, 0, 1, _, '<'),
    sub_atom(C, _, 1, 0, '>'),
    !,
    sub_atom(C, 1, _, 1, D),
    (   sub_atom(B, _, 2, 0, 'ID')
    ->  (   flag('hmac-key', Key)
        ->  hmac_sha(Key, D, E, [algorithm(sha1)])
        ;   sha_hash(D, E, [algorithm(sha1)])
        ),
        atom_codes(F, E),
        base64xml(F, G),
        write(G)
    ;   write(D)
    ).
wcf(A, _) :-
    atom(A),
    sub_atom(A, 0, 1, _, '_'),
    !,
    sub_atom(A, 1, _, 0, B),
    write(B).
wcf(A, _) :-
    with_output_to(atom(B), wg(A)),
    write(B).

indent:-
    nb_getval(indentation, A),
    tab(A).

indentation(C) :-
    nb_getval(indentation, A),
    B is A+C,
    nb_setval(indentation, B).


% ----------------------------
% EAM (Euler Abstract Machine)
% ----------------------------
%
% In a nutshell:
%
% 1/ Select rule P => C
% 2/ Prove P & NOT(C) (backward chaining) and if it fails backtrack to 1/
% 3/ If P & NOT(C) assert C (forward chaining) and remove brake
% 4/ If C = answer(A) and tactic limited-answer stop, else backtrack to 2/
% 5/ If brake or tactic linear-select stop, else start again at 1/
%

eam(Recursion) :-
    (   cnt(tr),
        (   flag(debug)
        ->  format(user_error, 'eam/1 entering recursion ~w~n', [Recursion]),
            flush_output(user_error)
        ;   true
        ),
        (   flag('max-inferences', MaxInf),
            statistics(inferences, Inf),
            Inf > MaxInf
        ->  throw(max_inferences_exceeded(MaxInf))
        ;   true
        ),
        implies(Prem, Conc, Src),
        (   flag('pass-merged')
        ->  Src = '<http://eulersharp.sourceforge.net/2003/03swap/pass-all>'
        ;   true
        ),
        ignore(Prem = true),
        (   flag(nope),
            \+flag('rule-histogram')
        ->  true
        ;   copy_term_nat('<http://www.w3.org/2000/10/swap/log#implies>'(Prem, Conc), Rule)
        ),
        (   flag(debug)
        ->  format(user_error, '. eam/1 selecting rule ~q~n', [implies(Prem, Conc, Src)]),
            flush_output(user_error)
        ;   true
        ),
        (   flag('no-ucall')
        ->  catch(call_residue_vars(call(Prem), []), Exc,
                (   Exc = error(existence_error(procedure, _), _)
                ->  fail
                ;   throw(Exc)
                )
            )
        ;   catch(call_residue_vars(ucall(Prem), []), Exc,
                (   Exc = error(existence_error(procedure, _), _)
                ->  fail
                ;   throw(Exc)
                )
            )
        ),
        (   (   Conc = false
            ;   Conc = answer(false, void, void)
            )
        ->  with_output_to(atom(PN3), writeq('<http://www.w3.org/2000/10/swap/log#implies>'(Prem, false))),
            (   flag('ignore-inference-fuse')
            ->  format(user_error, '** ERROR ** eam ** ~w~n', [inference_fuse(PN3)]),
                fail
            ;   throw(inference_fuse(PN3))
            )
        ;   true
        ),
        \+atom(Conc),
        \+is_list(Conc),
        (   flag('rule-histogram'),
            copy_term_nat(Rule, RuleL)
        ->  lookup(RTP, tp, RuleL),
            catch(cnt(RTP), _, nb_setval(RTP, 0))
        ;   true
        ),
        cnt(tp),
        djiti_conc(Conc, Concd),
        (   Concd = ':-'(Head, Body)
        ->  \+clause(Head, Body)
        ;   (   Concd = '<http://www.w3.org/2000/10/swap/log#implies>'(_, _)
            ->  copy_term_nat(Concd, Concc),
                labelvars(Concc, 0, _, avar),
                \+cc(Concc),
                assertz(cc(Concc))
            ;   (   flag('no-ucall')
                ->  \+catch(call(Concd), _, fail)
                ;   \+catch(ucall(Concd), _, fail)
                )
            )
        ),
        (   flag('rule-histogram')
        ->  lookup(RTC, tc, RuleL),
            catch(cnt(RTC), _, nb_setval(RTC, 0))
        ;   true
        ),
        (   Concd = (_, _),
            conj_list(Concd, Cl)
        ->  length(Cl, Ci),
            cnt(tc, Ci)
        ;   cnt(tc)
        ),
        (   Concd \= '<http://eulersharp.sourceforge.net/2003/03swap/log-rules#transaction>'(_, _),
            Concd \= ':-'(_, _)
        ->  nb_getval(wn, W),
            labelvars(Prem-Concd, W, N),        % failing when Prem contains attributed variables
            nb_setval(wn, N)
        ;   true
        ),
        (   flag(debug)
        ->  format(user_error, '... eam/1 assert step ~q~n', [Concd]),
            flush_output(user_error)
        ;   true
        ),
        conj_list(Concd, La),
        couple(La, La, Lc),
        findall([D, F],
            (   member([D, D], Lc),
                unify(D, F),
                (   F = '<http://www.w3.org/2000/10/swap/log#implies>'(_, _)
                ->  true
                ;   catch(\+F, _, true)
                )
            ),
            Ld
        ),
        couple(Ls, Le, Ld),
        conj_list(Concs, Ls),
        conj_list(Conce, Le),
        astep(Src, Prem, Concd, Conce, Rule),
        (   (   Concs = answer(_, _, _)
            ;   Concs = (answer(_, _, _), _)
            )
        ->  cnt(answer_count)
        ;   true
        ),
        nb_getval(answer_count, AnswerCount),
        (   flag('limited-answer', AnswerLimit),
            AnswerCount >= AnswerLimit
        ->  (   flag(strings)
            ->  true
            ;   w3
            )
        ;   retract(brake),
            fail
        )
    ;   (   brake
        ;   flag(tactic, 'linear-select')
        ),
        (   R is Recursion+1,
            (   \+recursion(R)
            ->  assertz(recursion(R))
            ;   true
            ),
            nb_getval(limit, Limit),
            Recursion < Limit,
            eam(R)
        ;   (   flag(strings)
            ->  true
            ;   (   flag('pass-only-new')
                ->  true
                ;   open_null_stream(Ws),
                    tell(Ws),
                    nb_getval(wn, Wn),
                    w3,
                    forall(
                        retract(keep_ng(NG)),
                        (   wt(NG),
                            nl
                        )
                    ),
                    forall(
                        retract(keep_ng(NG)),
                        (   wt(NG),
                            nl
                        )
                    ),
                    retractall(pfx(_, _)),
                    retractall(wpfx(_)),
                    nb_setval(wn, Wn),
                    nb_setval(output_statements, 0),
                    nb_setval(lemma_cursor, 0),
                    forall(
                        apfx(Pfx, Uri),
                        assertz(pfx(Pfx, Uri))
                    ),
                    told,
                    (   flag('output', Output)
                    ->  tell(Output)
                    ;   true
                    ),
                    w3,
                    forall(
                        retract(keep_ng(NG)),
                        (   wt(NG),
                            nl
                        )
                    ),
                    forall(
                        retract(keep_ng(NG)),
                        (   wt(NG),
                            nl
                        )
                    )
                )
            )
        ;   true
        ),
        !
    ;   assertz(brake),
        exogen,
        eam(Recursion)
    ).

astep(A, B, Cd, Cn, Rule) :-        % astep(Source, Premise, Conclusion, Conclusion_unique, Rule)
    (   Cn = (Dn, En)
    ->  functor(Dn, P, N),
        (   \+pred(P),
            P \= '<http://eulersharp.sourceforge.net/2003/03swap/log-rules#finalize>',
            P \= '<http://eulersharp.sourceforge.net/2003/03swap/log-rules#relabel>',
            P \= '<http://eulersharp.sourceforge.net/2003/03swap/log-rules#transaction>',
            P \= '<http://www.w3.org/2000/10/swap/log#implies>',
            P \= '<http://www.w3.org/2000/10/swap/log#callWithCleanup>',
            N = 2
        ->  assertz(pred(P))
        ;   true
        ),
        (   Dn \= '<http://www.w3.org/2000/10/swap/log#implies>'(_, _),
            catch(call(Dn), _, fail)
        ->  true
        ;   djiti_assertz(Dn),
            (   flag('pass-only-new'),
                Dn \= answer(_, _, _),
                \+pass_only_new(Dn)
            ->  assertz(pass_only_new(Dn))
            ;   true
            ),
            (   flag(nope)
            ->  true
            ;   (   B = '<http://eulersharp.sourceforge.net/2003/03swap/log-rules#transaction>'(P1, Q1),
                    Rule = '<http://www.w3.org/2000/10/swap/log#implies>'(Q6, R6),
                    prfstep('<http://eulersharp.sourceforge.net/2003/03swap/log-rules#transaction>'(P1, Q1), Q3, Q4, _,
                        '<http://www.w3.org/2000/10/swap/log#implies>'(P6, Q6), forward, A)
                ->  assertz(prfstep(Dn, Q3, Q4, Cd, '<http://www.w3.org/2000/10/swap/log#implies>'(P6, R6), forward, A))
                ;   term_index(B, Pnd),
                    assertz(prfstep(Dn, B, Pnd, Cd, Rule, forward, A))
                )
            )
        ),
        astep(A, B, Cd, En, Rule)
    ;   (   Cn = true
        ->  true
        ;   functor(Cn, P, N),
            (   \+pred(P),
                P \= '<http://eulersharp.sourceforge.net/2003/03swap/log-rules#finalize>',
                P \= '<http://eulersharp.sourceforge.net/2003/03swap/log-rules#relabel>',
                P \= '<http://eulersharp.sourceforge.net/2003/03swap/log-rules#transaction>',
                P \= '<http://www.w3.org/2000/10/swap/log#callWithCleanup>',
                P \= '<http://www.w3.org/2000/10/swap/log#implies>',
                N = 2
            ->  assertz(pred(P))
            ;   true
            ),
            (   Cn \= '<http://www.w3.org/2000/10/swap/log#implies>'(_, _),
                catch(call(Cn), _, fail)
            ->  true
            ;   djiti_assertz(Cn),
                (   flag('pass-only-new'),
                    Cn \= answer(_, _, _),
                    \+pass_only_new(Cn)
                ->  assertz(pass_only_new(Cn))
                ;   true
                ),
                (   flag(nope)
                ->  true
                ;   (   B = '<http://eulersharp.sourceforge.net/2003/03swap/log-rules#transaction>'(P1, Q1),
                        Rule = '<http://www.w3.org/2000/10/swap/log#implies>'(Q6, R6),
                        prfstep('<http://eulersharp.sourceforge.net/2003/03swap/log-rules#transaction>'(P1, Q1), Q3, Q4, _,
                            '<http://www.w3.org/2000/10/swap/log#implies>'(P6, Q6), forward, A)
                    ->  assertz(prfstep(Cn, Q3, Q4, Cd, '<http://www.w3.org/2000/10/swap/log#implies>'(P6, R6), forward, A))
                    ;   term_index(B, Pnd),
                        assertz(prfstep(Cn, B, Pnd, Cd, Rule, forward, A))
                    )
                )
            )
        )
    ).

istep(Src, Prem, Conc, Rule) :-        % istep(Source, Premise, Conclusion, Rule)
    copy_term_nat(Prem, Prec),
    labelvars(Prec, 0, _),
    term_index(Prec, Pnd),
    (   \+prfstep(Conc, Prec, Pnd, Conc, Rule, backward, Src)
    ->  assertz(prfstep(Conc, Prec, Pnd, Conc, Rule, backward, Src))
    ;   true
    ).

pstep(Rule) :-
    copy_term_nat(Rule, RuleL),
    lookup(RTC, tc, RuleL),
    catch(cnt(RTC), _, nb_setval(RTC, 0)),
    lookup(RTP, tp, RuleL),
    catch(cnt(RTP), _, nb_setval(RTP, 0)).

hstep(A, B) :-
    (   nonvar(A),
        A = exopred(P, S, O)
    ->  pred(P),
        U =.. [P, S, O],
        qstep(U, B)
    ;   qstep(A, B)
    ).

qstep(A, B) :-
    prfstep(A, B, _, _, _, _, _).
qstep(A, true) :-
    (   nonvar(A)
    ->  (   A =.. [P, [S1, S2|S3], O]
        ->  B =.. [P, S1, S2, S3, O]
        ;   (   A =.. [P, S, literal(O1, O2)]
            ->  B =.. [P, S, O1, O2]
            ;   B = A
            )
        )
    ;   pred(P),
        A =.. [P, _, _],
        B = A
    ),
    catch(clause(B, true), _, fail),
    \+prfstep(A, _, _, _, _, _, _).

%
% DJITI (Deep Just In Time Indexing)
%

djiti_answer(answer((A, B)), (C, D)) :-
    !,
    djiti_answer(answer(A), C),
    djiti_answer(answer(B), D).
djiti_answer(answer(A), answer(P, S, O)) :-
    (   nonvar(A)
    ;   atom(P),
        S \= void
    ),
    A =.. [P, S, O],
    !.
djiti_answer(answer(exopred(P, S, O)), answer(P, S, O)) :-
    (   var(S)
    ;   S \= void
    ),
    !.
djiti_answer(answer(A), answer(A, void, void)) :-
    !.
djiti_answer(A, A).

djiti_conc(':-'(exopred(P, S, O), B), ':-'(A, B)) :-
    !,
    A =.. [P, S, O].
djiti_conc(answer((A, B), void, void), (answer(A, void, void), D)) :-
    !,
    djiti_conc(answer(B, void, void), D).
djiti_conc(A, A).

djiti_fact(answer(P, S, O), answer(P, S, O)) :-
    atomic(P),
    !,
    (   P \= '<http://eulersharp.sourceforge.net/2003/03swap/log-rules#finalize>',
        P \= '<http://www.w3.org/2000/10/swap/log#callWithCleanup>',
        \+pred(P)
    ->  assertz(pred(P))
    ;   true
    ).
djiti_fact(implies(A, B, C), implies(A, B, C)) :-
    nonvar(B),
    conj_list(B, D),
    forall(
        member(E, D),
        (   unify(E, F),
            F =.. [P, _, _],
            (   \+fpred(P)
            ->  assertz(fpred(P))
            ;   true
            )
        )
    ),
    !.
djiti_fact('<http://www.w3.org/2000/10/swap/log#implies>'(A, B), C) :-
    nonvar(B),
    (   conj_list(B, D)
    ->  true
    ;   D = B
    ),
    forall(
        member(E, D),
        (   unify(E, F),
            (   F =.. [P, _, _],
                \+fpred(P)
            ->  assertz(fpred(P))
            ;   true
            )
        )
    ),
    !,
    (   retwist(A, B, Z)
    ->  true
    ;   Z = '<>'
    ),
    makevars(implies(A, B, Z), C, zeta).
djiti_fact(':-'(A, B), ':-'(C, D)) :-
    !,
    makevars((A, B), (C, E), eta),
    copy_term_nat('<http://www.w3.org/2000/10/swap/log#implies>'(E, C), F),
    (   flag(nope)
    ->  D = E
    ;   (   retwist(E, C, G)
        ->  true
        ;   G = '<>'
        ),
        (   E = when(H, I)
        ->  conj_append(I, istep(G, E, C, F), J),
            D = when(H, J)
        ;   conj_append(E, istep(G, E, C, F), D)
        )
    ).
djiti_fact('<http://www.w3.org/2000/10/swap/log#dcg>'(_, literal(A, type('<http://www.w3.org/2001/XMLSchema#string>'))), B) :-
    !,
    read_term_from_atom(A, C, []),
    dcg_translate_rule(C, B).
djiti_fact(A, A) :-
    ground(A),
    A =.. [P, _, _],
    (   P \= '<http://eulersharp.sourceforge.net/2003/03swap/log-rules#finalize>',
        P \= '<http://eulersharp.sourceforge.net/2003/03swap/log-rules#relabel>',
        P \= '<http://www.w3.org/2000/10/swap/log#callWithCleanup>',
        P \= '<http://www.w3.org/1999/02/22-rdf-syntax-ns#first>',
        P \= '<http://www.w3.org/1999/02/22-rdf-syntax-ns#rest>',
        P \= query,
        P \= pfx,
        P \= flag,
        P \= semantics,
        \+pred(P)
    ->  assertz(pred(P))
    ;   true
    ),
    !.
djiti_fact(A, A).

djiti_assertz(A) :-
    djiti_fact(A, B),
    assertz(B).

%
% Built-ins
%

'<http://www.w3.org/1999/02/22-rdf-syntax-ns#first>'(X, Y) :-
    when(
        (   nonvar(X)
        ;   nonvar(Y)
        ),
        (   X = [Y|_]
        )
    ),
    !.

'<http://www.w3.org/1999/02/22-rdf-syntax-ns#rest>'(X, Y) :-
    when(
        (   nonvar(X)
        ;   nonvar(Y)
        ),
        (   X = [_|Y]
        )
    ),
    !.

'<http://www.w3.org/2000/10/swap/crypto#md5>'(literal(A, type('<http://www.w3.org/2001/XMLSchema#string>')), literal(B, type('<http://www.w3.org/2001/XMLSchema#string>'))) :-
    when(
        (   nonvar(A)
        ),
        (   md5_hash(A, B, [])
        )
    ).

'<http://www.w3.org/2000/10/swap/crypto#sha>'(literal(A, type('<http://www.w3.org/2001/XMLSchema#string>')), literal(B, type('<http://www.w3.org/2001/XMLSchema#string>'))) :-
    when(
        (   nonvar(A)
        ),
        (   sha_hash(A, C, [algorithm(sha1)]),
            hash_atom(C, B)
        )
    ).

'<http://www.w3.org/2000/10/swap/crypto#sha256>'(literal(A, type('<http://www.w3.org/2001/XMLSchema#string>')), literal(B, type('<http://www.w3.org/2001/XMLSchema#string>'))) :-
    when(
        (   nonvar(A)
        ),
        (   sha_hash(A, C, [algorithm(sha256)]),
            hash_atom(C, B)
        )
    ).

'<http://www.w3.org/2000/10/swap/crypto#sha512>'(literal(A, type('<http://www.w3.org/2001/XMLSchema#string>')), literal(B, type('<http://www.w3.org/2001/XMLSchema#string>'))) :-
    when(
        (   nonvar(A)
        ),
        (   sha_hash(A, C, [algorithm(sha512)]),
            hash_atom(C, B)
        )
    ).

'<http://www.w3.org/2000/10/swap/graph#difference>'(A, B) :-
    when(
        (   nonvar(A)
        ),
        (   makevars(A, C, delta),
            difference(C, B)
        )
    ).

'<http://www.w3.org/2000/10/swap/graph#intersection>'(A, B) :-
    when(
        (   nonvar(A)
        ),
        (   intersect(A, B)
        )
    ).

'<http://www.w3.org/2000/10/swap/graph#length>'(A, B) :-
    when(
        (   nonvar(A)
        ),
        (   conj_list(A, D),
            (   ground(D)
            ->  distinct(D, C)
            ;   C = D
            ),
            length(C, B)
        )
    ).

'<http://www.w3.org/2000/10/swap/graph#list>'(A, B) :-
    conj_list(A, B).

'<http://www.w3.org/2000/10/swap/graph#member>'(A, B) :-
    when(
        (   nonvar(A)
        ),
        (   conj_list(A, C),
            member(B, C)
        )
    ).

'<http://www.w3.org/2000/10/swap/graph#notMember>'(A, B) :-
    when(
        (   nonvar(A)
        ),
        (   conj_list(A, C),
            \+member(B, C)
        )
    ).

'<http://www.w3.org/2000/10/swap/graph#renameBlanks>'(A, B) :-
    when(
        (   nonvar(A)
        ),
        (   copy_term_nat(A, C),
            findvars(C, D, beta),
            makevars(C, B, beta(D)),
            nb_getval(wn, W),
            labelvars(B, W, N),
            nb_setval(wn, N)
        )
    ).

'<http://www.w3.org/2000/10/swap/graph#union>'(A, B) :-
    when(
        (   nonvar(A)
        ),
        (   conjoin(A, B)
        )
    ).

'<http://www.w3.org/2000/10/swap/list#append>'(A, B) :-
    when(
        (   nonvar(A)
        ),
        (   getlist(A, C),
            (   member(D, C),
                var(D),
                var(B)
            ->  true
            ;   append(C, B)
            )
        )
    ).

'<http://www.w3.org/2000/10/swap/list#first>'(A, B) :-
    when(
        (   nonvar(A)
        ),
        (   getlist(A, C),
            C = [B|D],
            nonvar(D)
        )
    ).

'<http://www.w3.org/2000/10/swap/list#firstRest>'([A|B], [A, B]).

'<http://www.w3.org/2000/10/swap/list#in>'(A, B) :-
    when(
        (   nonvar(B)
        ),
        (   getlist(B, C),
            member(A, C)
        )
    ).

'<http://www.w3.org/2000/10/swap/list#iterate>'(A, [B, C]) :-
    when(
        (   nonvar(A)
        ),
        (   getlist(A, D),
            nth0(B, D, C)
        )
    ).

'<http://www.w3.org/2000/10/swap/list#last>'(A, B) :-
    when(
        (   nonvar(A)
        ),
        (   getlist(A, C),
            last(C, B)
        )
    ).

'<http://www.w3.org/2000/10/swap/list#length>'(A, B) :-
    when(
        (   nonvar(A)
        ),
        (   (   getlist(A, C)
            ->  true
            ;   conj_list(A, D),
                (   ground(D)
                ->  distinct(D, C)
                ;   C = D
                )
            ),
            length(C, B)
        )
    ).

'<http://www.w3.org/2000/10/swap/list#map>'([A, B], C) :-
    when(
        (   nonvar(A),
            nonvar(B)
        ),
        (   getlist(A, D),
            findall(E,
                (   member(F, D),
                    G =.. [B, F, E],
                    G
                ),
                C
            )
        )
    ).

'<http://www.w3.org/2000/10/swap/list#member>'(A, B) :-
    when(
        (   nonvar(A)
        ),
        (   getlist(A, C),
            member(B, C)
        )
    ).

'<http://www.w3.org/2000/10/swap/list#memberAt>'([A, B], C) :-
    when(
        (   nonvar(A)
        ),
        (   nth0(B, A, C)
        )
    ).

'<http://www.w3.org/2000/10/swap/list#multisetEqualTo>'(A, B) :-
    when(
        (   nonvar(A),
            nonvar(B)
        ),
        (   sort(0, @=<, A, C),
            sort(0, @=<, B, C)
        )
    ).

'<http://www.w3.org/2000/10/swap/list#multisetNotEqualTo>'(A, B) :-
    \+'<http://www.w3.org/2000/10/swap/list#multisetEqualTo>'(A, B).

'<http://www.w3.org/2000/10/swap/list#notMember>'(A, B) :-
    when(
        (   nonvar(A)
        ),
        (   getlist(A, C),
            \+member(B, C)
        )
    ).

'<http://www.w3.org/2000/10/swap/list#remove>'([A, B], C) :-
    when(
        (   nonvar(A),
            nonvar(B)
        ),
        (   selectchk(B, A, D),
            (   \+member(B, D)
            ->  C = D
            ;   '<http://www.w3.org/2000/10/swap/list#remove>'([D, B], C)
            )
        )
    ).

'<http://www.w3.org/2000/10/swap/list#removeAt>'([A, B], C) :-
    when(
        (   nonvar(A)
        ),
        (   nth0(B, A, D),
            selectchk(D, A, C)
        )
    ).

'<http://www.w3.org/2000/10/swap/list#removeDuplicates>'(A, B) :-
    when(
        (   nonvar(A)
        ),
        (   getlist(A, C),
            list_to_set(C, B)
        )
    ).

'<http://www.w3.org/2000/10/swap/list#rest>'(A, B) :-
    when(
        (   nonvar(A)
        ),
        (   getlist(A, C),
            C = [_|B]
        )
    ).

'<http://www.w3.org/2000/10/swap/list#setEqualTo>'(A, B) :-
    when(
        (   nonvar(A),
            nonvar(B)
        ),
        (   getlist(A, C),
            getlist(B, D),
            sort(C, E),
            sort(D, E)
        )
    ).

'<http://www.w3.org/2000/10/swap/list#setNotEqualTo>'(A, B) :-
    \+'<http://www.w3.org/2000/10/swap/list#setEqualTo>'(A, B).

'<http://www.w3.org/2000/10/swap/list#sort>'(A, B) :-
    when(
        (   nonvar(A)
        ),
        (   sort(A, B)
        )
    ).

'<http://www.w3.org/2000/10/swap/list#unique>'(A, B) :-
    when(
        (   nonvar(A)
        ),
        (   list_to_set(A, B)
        )
    ).

'<http://www.w3.org/2000/10/swap/log#becomes>'(A, B) :-
    catch(call(A), _, fail),
    A \= B,
    unify(A, C),
    conj_list(C, D),
    forall(
        member(E, D),
        (   (   E = '<http://www.w3.org/2000/10/swap/log#implies>'(Prem, Conc)
            ->  retract(implies(Prem, Conc, Src)),
                assertz(retwist(Prem, Conc, Src))
            ;   (   E = ':-'(Ci, Pi),
                    Pi \= true
                ->  (   flag(nope)
                    ->  Ph = Pi
                    ;   (   Pi = when(Ai, Bi)
                        ->  conj_append(Bi, istep(Si, Pi, Ci, _), Bh),
                            Ph = when(Ai, Bh)
                        ;   conj_append(Pi, istep(Si, Pi, Ci, _), Ph)
                        ),
                        ':-'(Ci, Ph),
                        assertz(retwist(Pi, Ci, Si))
                    ),
                    retract(':-'(Ci, Ph))
                ;   E \= ':-'(_, true),
                    retract(E)
                )
            ),
            djiti_answer(answer(E), Z),
            retractall(Z),
            (   flag('pass-only-new'),
                pass_only_new(E)
            ->  retract(pass_only_new(E))
            ;   true
            )
        )
    ),
    nb_getval(wn, W),
    labelvars(B, W, N),
    nb_setval(wn, N),
    unify(B, F),
    conj_list(F, G),
    forall(
        member(H, G),
        (   djiti_assertz(H),
            (   flag('pass-only-new'),
                \+pass_only_new(H)
            ->  assertz(pass_only_new(H))
            ;   true
            )
        )
    ).

'<http://www.w3.org/2000/10/swap/log#bound>'(X, Y) :-
    (   nonvar(X)
    ->  Y = true
    ;   Y = false
    ).

'<http://www.w3.org/2000/10/swap/log#call>'(A, B) :-
    call(A),
    catch(call(B), _, fail),
    (   flag(nope)
    ->  true
    ;   copy_term_nat('<http://www.w3.org/2000/10/swap/log#implies>'(B, '<http://www.w3.org/2000/10/swap/log#call>'(A, B)), C),
        istep('<>', B, '<http://www.w3.org/2000/10/swap/log#call>'(A, B), C)
    ).

'<http://www.w3.org/2000/10/swap/log#callNotBind>'(A, B) :-
    \+ \+call(A),
    \+ \+catch(call(B), _, fail),
    (   flag(nope)
    ->  true
    ;   copy_term_nat('<http://www.w3.org/2000/10/swap/log#implies>'(B, '<http://www.w3.org/2000/10/swap/log#call>'(A, B)), C),
        istep('<>', B, '<http://www.w3.org/2000/10/swap/log#call>'(A, B), C)
    ).

'<http://www.w3.org/2000/10/swap/log#callWithCleanup>'(A, B) :-
    call_cleanup(A, B),
    (   flag(nope)
    ->  true
    ;   conj_append(A, B, C),
        copy_term_nat('<http://www.w3.org/2000/10/swap/log#implies>'(C, '<http://www.w3.org/2000/10/swap/log#callWithCleanup>'(A, B)), D),
        istep('<>', C, '<http://www.w3.org/2000/10/swap/log#callWithCleanup>'(A, B), D)
    ).

'<http://www.w3.org/2000/10/swap/log#callWithOptional>'(A, B) :-
    call(A),
    (   \+catch(call(B), _, fail)
    ->  true
    ;   catch(call(B), _, fail),
        (   flag(nope)
        ->  true
        ;   conj_append(A, B, C),
            copy_term_nat('<http://www.w3.org/2000/10/swap/log#implies>'(C, '<http://www.w3.org/2000/10/swap/log#callWithOptional>'(A, B)), D),
            istep('<>', C, '<http://www.w3.org/2000/10/swap/log#callWithOptional>'(A, B), D)
        )
    ).

'<http://www.w3.org/2000/10/swap/log#collectAllIn>'(B, A) :-
    \+flag(restricted),
    nonvar(A),
    A \= [_, _],
    !,
    when(
        (   nonvar(B)
        ),
        (   reset_gensym,
            tmp_file(Tmp1),
            open(Tmp1, write, Ws1, [encoding(utf8)]),
            tell(Ws1),
            (   flag('no-qnames')
            ->  true
            ;   forall(
                    pfx(C, D),
                    format('@prefix ~w ~w.~n', [C, D])
                ),
                nl
            ),
            labelvars(A, 0, _),
            wt(A),
            write('.'),
            nl,
            told,
            (   flag('output', Output)
            ->  tell(Output)
            ;   true
            ),
            tmp_file(Tmp2),
            open(Tmp2, write, Ws2, [encoding(utf8)]),
            tell(Ws2),
            (   flag('no-qnames')
            ->  true
            ;   forall(
                    pfx(E, F),
                    format('@prefix ~w ~w.~n', [E, F])
                ),
                nl
            ),
            write('{'),
            wt('<http://www.w3.org/2000/10/swap/log#collectAllIn>'(B, _)),
            write('} => {'),
            wt('<http://www.w3.org/2000/10/swap/log#collectAllIn>'(B, _)),
            write('}.'),
            nl,
            told,
            (   flag('output', Output)
            ->  tell(Output)
            ;   true
            ),
            tmp_file(Tmp3),
            !,
            (   current_prolog_flag(windows, true)
            ->  A1 = ['cmd.exe', '/C']
            ;   A1 = []
            ),
            (   current_prolog_flag(argv, Argv),
                append(Argu, ['--'|_], Argv)
            ->  append(Argu, ['--'], A2)
            ;   A2 = ['eye']
            ),
            (   flag(quiet)
            ->  Quiet = '--quiet'
            ;   Quiet = ''
            ),
            append([A1, A2, ['--nope', Quiet, Tmp1, '--query', Tmp2, '>', Tmp3]], A4),
            findall([G, ' '],
                (   member(G, A4)
                ),
                H
            ),
            flatten(H, I),
            atomic_list_concat(I, J),
            (   catch(exec(J, _), _, fail)
            ->  n3_n3p(Tmp3, semantics),
                absolute_uri(Tmp3, Tmp),
                atomic_list_concat(['<', Tmp, '>'], Res),
                semantics(Res, L),
                conj_list(K, L),
                labelvars(K, 0, _),
                B = [_, _, M],
                K = '<http://www.w3.org/2000/10/swap/log#collectAllIn>'([_, _, M], _),
                delete_file(Tmp1),
                delete_file(Tmp2),
                delete_file(Tmp3)
            ;   delete_file(Tmp1),
                delete_file(Tmp2),
                delete_file(Tmp3),
                fail
            )
        )
    ).
'<http://www.w3.org/2000/10/swap/log#collectAllIn>'([A, B, C], Sc) :-
    within_scope(Sc),
    nonvar(B),
    \+is_list(B),
    catch(findall(A, B, E), _, E = []),
    (   flag(warn)
    ->  copy_term_nat([A, B, E], [Ac, Bc, Ec]),
        labelvars([Ac, Bc, Ec], 0, _),
        (   fact('<http://www.w3.org/2000/10/swap/log#collectAllIn>'([Ac, Bc, G], Sc))
        ->  (   E \= G
            ->  format(user_error, '** WARNING ** conflicting_collectAllIn_answers ~w VERSUS ~w~n', [[A, B, G], [A, B, E]]),
                flush_output(user_error)
            ;   true
            )
        ;   assertz(fact('<http://www.w3.org/2000/10/swap/log#collectAllIn>'([Ac, Bc, Ec], Sc)))
        )
    ;   true
    ),
    E = C.

'<http://www.w3.org/2000/10/swap/log#conclusion>'(A, B) :-
    when(
        (   nonvar(A)
        ),
        (   reset_gensym,
            tmp_file(Tmp1),
            open(Tmp1, write, Ws1, [encoding(utf8)]),
            tell(Ws1),
            (   flag('no-qnames')
            ->  true
            ;   forall(
                    pfx(C, D),
                    format('@prefix ~w ~w.~n', [C, D])
                ),
                nl
            ),
            labelvars(A, 0, _),
            wt(A),
            write('.'),
            nl,
            told,
            (   flag('output', Output)
            ->  tell(Output)
            ;   true
            ),
            tmp_file(Tmp2),
            !,
            (   current_prolog_flag(windows, true)
            ->  A1 = ['cmd.exe', '/C']
            ;   A1 = []
            ),
            (   current_prolog_flag(argv, Argv),
                append(Argu, ['--'|_], Argv)
            ->  append(Argu, ['--'], A2)
            ;   A2 = ['eye']
            ),
            (   flag(quiet)
            ->  Quiet = '--quiet'
            ;   Quiet = ''
            ),
            append([A1, A2, ['--nope', Quiet, Tmp1, '--pass-all', '>', Tmp2]], A4),
            findall([G, ' '],
                (   member(G, A4)
                ),
                H
            ),
            flatten(H, I),
            atomic_list_concat(I, J),
            (   catch(exec(J, _), _, fail)
            ->  n3_n3p(Tmp2, semantics),
                absolute_uri(Tmp2, Tmp),
                atomic_list_concat(['<', Tmp, '>'], Res),
                semantics(Res, L),
                conj_list(B, L),
                labelvars(B, 0, _),
                delete_file(Tmp1),
                delete_file(Tmp2)
            ;   delete_file(Tmp1),
                delete_file(Tmp2),
                fail
            )
        )
    ).

'<http://www.w3.org/2000/10/swap/log#conjunction>'(A, B) :-
    when(
        (   nonvar(A)
        ),
        (   conjoin(A, M),
            unify(M, B)
        )
    ).

'<http://www.w3.org/2000/10/swap/log#content>'(A, B) :-
    \+flag(restricted),
    '<http://www.w3.org/2000/10/swap/log#semantics>'(A, C),
    '<http://www.w3.org/2000/10/swap/log#n3String>'(C, B).

'<http://www.w3.org/2000/10/swap/log#copy>'(X, Y) :-
    copy_term_nat(X, Y).

'<http://www.w3.org/2000/10/swap/log#dtlit>'([A, B], C) :-
    when(
        (   ground(A)
        ;   nonvar(C)
        ),
        (   ground(A),
            (   var(B)
            ->  (   member(B, ['<http://www.w3.org/2001/XMLSchema#integer>', '<http://www.w3.org/2001/XMLSchema#double>',
                    '<http://www.w3.org/2001/XMLSchema#date>', '<http://www.w3.org/2001/XMLSchema#time>', '<http://www.w3.org/2001/XMLSchema#dateTime>',
                    '<http://www.w3.org/2001/XMLSchema#yearMonthDuration>', '<http://www.w3.org/2001/XMLSchema#dayTimeDuration>', '<http://www.w3.org/2001/XMLSchema#duration>']),
                    dtlit([A, B], C),
                    getnumber(C, D),
                    dtlit([_, B], D)
                ->  true
                ;   (   dtlit([A, '<http://www.w3.org/2001/XMLSchema#boolean>'], C),
                        getbool(C, _),
                        B = '<http://www.w3.org/2001/XMLSchema#boolean>'
                    ->  true
                    ;   B = '<http://www.w3.org/2001/XMLSchema#string>',
                        C = A
                    )
                )
            ;   A = literal(E, _),
                (   B = prolog:atom
                ->  C = E
                ;   C = literal(E, type(B))
                ),
                !
            )
        ;   nonvar(C),
            dtlit([A, B], C)
        )
    ).

'<http://www.w3.org/2000/10/swap/log#equalTo>'(X, Y) :-
    unify(X, Y).

'<http://www.w3.org/2000/10/swap/log#forAllIn>'([A, B], Sc) :-
    within_scope(Sc),
    when(
        (   nonvar(A),
            nonvar(B)
        ),
        (   forall(A, B)
        )
    ).

'<http://www.w3.org/2000/10/swap/log#hasPrefix>'(A, B) :-
    when(
        (   nonvar(A)
        ),
        (   pfx(_, A)
        ->  B = true
        ;   B = false
        )
    ).

'<http://www.w3.org/2000/10/swap/log#ifThenElseIn>'(A, B) :-
    \+flag(restricted),
    nonvar(B),
    B \= [_, _],
    !,
    when(
        (   nonvar(A)
        ),
        (   reset_gensym,
            tmp_file(Tmp1),
            open(Tmp1, write, Ws1, [encoding(utf8)]),
            tell(Ws1),
            (   flag('no-qnames')
            ->  true
            ;   forall(
                    pfx(C, D),
                    format('@prefix ~w ~w.~n', [C, D])
                ),
                nl
            ),
            labelvars(B, 0, _),
            wt(B),
            write('.'),
            nl,
            told,
            (   flag('output', Output)
            ->  tell(Output)
            ;   true
            ),
            tmp_file(Tmp2),
            open(Tmp2, write, Ws2, [encoding(utf8)]),
            tell(Ws2),
            (   flag('no-qnames')
            ->  true
            ;   forall(
                    pfx(E, F),
                    format('@prefix ~w ~w.~n', [E, F])
                ),
                nl
            ),
            write('{'),
            wt('<http://www.w3.org/2000/10/swap/log#ifThenElseIn>'(A, _)),
            write('} => {'),
            wt('<http://www.w3.org/2000/10/swap/log#ifThenElseIn>'(A, _)),
            write('}.'),
            nl,
            told,
            (   flag('output', Output)
            ->  tell(Output)
            ;   true
            ),
            tmp_file(Tmp3),
            !,
            (   current_prolog_flag(windows, true)
            ->  A1 = ['cmd.exe', '/C']
            ;   A1 = []
            ),
            (   current_prolog_flag(argv, Argv),
                append(Argu, ['--'|_], Argv)
            ->  append(Argu, ['--'], A2)
            ;   A2 = ['eye']
            ),
            (   flag(quiet)
            ->  Quiet = '--quiet'
            ;   Quiet = ''
            ),
            append([A1, A2, ['--nope', Quiet, Tmp1, '--query', Tmp2, '>', Tmp3]], A4),
            findall([G, ' '],
                (   member(G, A4)
                ),
                H
            ),
            flatten(H, I),
            atomic_list_concat(I, J),
            (   catch(exec(J, _), _, fail)
            ->  n3_n3p(Tmp3, semantics),
                absolute_uri(Tmp3, Tmp),
                atomic_list_concat(['<', Tmp, '>'], Res),
                semantics(Res, L),
                conj_list(K, L),
                labelvars(K, 0, _),
                A = M,
                K = '<http://www.w3.org/2000/10/swap/log#ifThenElseIn>'(M, _),
                delete_file(Tmp1),
                delete_file(Tmp2),
                delete_file(Tmp3)
            ;   delete_file(Tmp1),
                delete_file(Tmp2),
                delete_file(Tmp3),
                fail
            )
        )
    ).
'<http://www.w3.org/2000/10/swap/log#ifThenElseIn>'([A, B, C], Sc) :-
    within_scope(Sc),
    when(
        (   nonvar(A),
            nonvar(B),
            nonvar(C)
        ),
        (   if_then_else(A, B, C)
        )
    ).

'<http://www.w3.org/2000/10/swap/log#implies>'(A, B) :-
    implies(U, V, _),
    unify(U, A),
    unify(V, B),
    (   commonvars(A, B, [])
    ->  labelvars(B, 0, _, avar)
    ;   true
    ),
    (   var(B)
    ->  true
    ;   B \= answer(_, _, _),
        B \= (answer(_, _, _), _)
    ).

'<http://www.w3.org/2000/10/swap/log#imports>'(_, X) :-
    \+flag(restricted),
    when(
        (   nonvar(X)
        ),
        (   (   scope(X)
            ->  true
            ;   sub_atom(X, 0, 1, _, '<'),
                sub_atom(X, _, 1, 0, '>'),
                sub_atom(X, 1, _, 1, Z),
                catch(
                    args([Z]),
                    Exc,
                    (   format(user_error, '** ERROR ** ~w **~n', [Exc]),
                        flush_output(user_error),
                        fail
                    )
                )
            )
        )
    ).

'<http://www.w3.org/2000/10/swap/log#includes>'(X, Y) :-
    within_scope(X),
    !,
    when(
        (   nonvar(Y)
        ),
        (   call(Y)
        )
    ).
'<http://www.w3.org/2000/10/swap/log#includes>'(X, Y) :-
    when(
        (   nonvar(X),
            nonvar(Y)
        ),
        (   X \= [_, _],
            conj_list(X, A),
            conj_list(Y, B),
            includes(A, B)
        )
    ).

'<http://www.w3.org/2000/10/swap/log#includesNotBind>'(X, Y) :-
    within_scope(X),
    !,
    when(
        (   nonvar(Y)
        ),
        (   \+ \+call(Y)
        )
    ).
'<http://www.w3.org/2000/10/swap/log#includesNotBind>'(X, Y) :-
    when(
        (   nonvar(X),
            nonvar(Y)
        ),
        (   conj_list(X, A),
            conj_list(Y, B),
            \+ \+includes(A, B)
        )
    ).

'<http://www.w3.org/2000/10/swap/log#inferences>'(A, B) :-
    '<http://www.w3.org/2000/10/swap/log#conclusion>'(A, C),
    (   nonvar(B)
    ->  intersect([B, C], M),
        unify(M, B)
    ;   B = C
    ).

'<http://www.w3.org/2000/10/swap/log#isomorphic>'(A, B) :-
    makevars([A, B], [C, D], beta),
    \+ \+unify(C, B),
    \+ \+unify(A, D).

'<http://www.w3.org/2000/10/swap/log#langlit>'([literal(A, type('<http://www.w3.org/2001/XMLSchema#string>')), literal(B, type('<http://www.w3.org/2001/XMLSchema#string>'))], literal(A, lang(B))).

'<http://www.w3.org/2000/10/swap/log#localN3String>'(A, literal(B, type('<http://www.w3.org/2001/XMLSchema#string>'))) :-
    term_variables(A, V),
    labelvars([A, V], 0, _, avar),
    with_output_to_chars((wq(V, allv), wt(A)), E),
    escape_string(E, F),
    atom_codes(B, F).

'<http://www.w3.org/2000/10/swap/log#localName>'(A, literal(B, type('<http://www.w3.org/2001/XMLSchema#string>'))) :-
    when(
        (   nonvar(A)
        ),
        (   sub_atom(A, 1, _, 1, C),
            (   sub_atom_last(C, _, 1, N, '#') ->
                sub_atom(C, _, N, 0, B)
                ;
                sub_atom_last(C, _, 1, N, '/') ->
                sub_atom(C, _, N, 0, B)
                ;
                sub_atom_last(C, _, 1, N, ':') ->
                sub_atom(C, _, N, 0, B)
            )
        )
    ).

'<http://www.w3.org/2000/10/swap/log#n3String>'(A, literal(B, type('<http://www.w3.org/2001/XMLSchema#string>'))) :-
    (   n3s(A, literal(B, type('<http://www.w3.org/2001/XMLSchema#string>')))
    ->  true
    ;   retractall(wpfx(_)),
        with_output_to_chars(wh, C1),
        retractall(wpfx(_)),
        \+ (C1 = [], \+flag('no-qnames')),
        numbervars(A),
        with_output_to_chars(wt(A), C2),
        append(C1, C2, C),
        escape_string(C, D),
        atom_codes(B, D),
        assertz(n3s(A, literal(B, type('<http://www.w3.org/2001/XMLSchema#string>'))))
    ).

'<http://www.w3.org/2000/10/swap/log#namespace>'(A, literal(B, type('<http://www.w3.org/2001/XMLSchema#string>'))) :-
    when(
        (   nonvar(A)
        ),
        (   sub_atom(A, 1, _, 1, C),
            (   sub_atom_last(C, N, 1, _, '#') ->
                M is N+1,
                sub_atom(C, 0, M, _, B)
                ;
                sub_atom_last(C, N, 1, _, '/') ->
                M is N+1,
                sub_atom(C, 0, M, _, B)
                ;
                sub_atom_last(C, N, 1, _, ':') ->
                M is N+1,
                sub_atom(C, 0, M, _, B)
            )
        )
    ).

'<http://www.w3.org/2000/10/swap/log#notEqualTo>'(X, Y) :-
    when(
        (   ground([X, Y])
        ),
        (   (   \+atomic(X),
                \+atomic(Y)
            ->  findvars([X, Y], Z, beta),
                Z = []
            ;   true
            ),
            \+'<http://www.w3.org/2000/10/swap/log#equalTo>'(X, Y)
        )
    ).

'<http://www.w3.org/2000/10/swap/log#notIncludes>'(X, Y) :-
    within_scope(X),
    !,
    when(
        (   nonvar(Y)
        ),
        (   \+call(Y)
        )
    ).
'<http://www.w3.org/2000/10/swap/log#notIncludes>'(X, Y) :-
    when(
        (   nonvar(X),
            nonvar(Y)
        ),
        (   X \= [_, _],
            conj_list(X, A),
            conj_list(Y, B),
            \+includes(A, B)
        )
    ).

'<http://www.w3.org/2000/10/swap/log#notIsomorphic>'(X, Y) :-
    \+'<http://www.w3.org/2000/10/swap/log#isomorphic>'(X, Y).

'<http://www.w3.org/2000/10/swap/log#parsedAsN3>'(literal(A, _), B) :-
    (   parsed_as_n3(A, B)
    ->  true
    ;   atom_codes(A, C),
        escape_string(D, C),
        atom_codes(E, D),
        tmp_file(Tmp),
        open(Tmp, write, Ws, [encoding(utf8)]),
        tell(Ws),
        writef(E, []),
        told,
        (   flag('output', Output)
        ->  tell(Output)
        ;   true
        ),
        atomic_list_concat(['<file://', Tmp, '>'], F),
        '<http://www.w3.org/2000/10/swap/log#semantics>'(F, B),
        assertz(parsed_as_n3(A, B))
    ).

'<http://www.w3.org/2000/10/swap/log#phrase>'([literal(A, type('<http://www.w3.org/2001/XMLSchema#string>'))|B], C) :-
    read_term_from_atom(A, D, [variables(B)]),
    findall(E,
        (   member(literal(E, type('<http://www.w3.org/2001/XMLSchema#string>')), C)
        ),
        F
    ),
    phrase(D, F, []).

'<http://www.w3.org/2000/10/swap/log#prefix>'(A, literal(B, type('<http://www.w3.org/2001/XMLSchema#string>'))) :-
    when(
        (   nonvar(A)
        ;   nonvar(B)
        ),
        (   pfx(C, A),
            sub_atom(C, 0, _, 1, B)
        )
    ).

'<http://www.w3.org/2000/10/swap/log#racine>'(A, B) :-
    when(
        (   nonvar(A)
        ),
        (   sub_atom(A, 1, _, 1, C),
            sub_atom(C, N, 1, _, '#'),
            sub_atom(C, 0, N, _, D),
            atomic_list_concat(['<', D, '>'], B)
        )
    ).

'<http://www.w3.org/2000/10/swap/log#rawType>'(A, B) :-
    raw_type(A, C),
    C = B.

'<http://www.w3.org/2000/10/swap/log#repeat>'(A, B) :-
    C is A-1,
    between(0, C, B).

'<http://www.w3.org/2000/10/swap/log#semantics>'(X, Y) :-
    \+flag(restricted),
    when(
        (   nonvar(X)
        ),
        (   (   semantics(X, L)
            ->  conj_list(Y, L)
            ;   sub_atom(X, 0, 1, _, '<'),
                sub_atom(X, _, 1, 0, '>'),
                sub_atom(X, 1, _, 1, Z),
                catch(
                    n3_n3p(Z, semantics),
                    Exc,
                    (   format(user_error, '** ERROR ** ~w **~n', [Exc]),
                        flush_output(user_error),
                        fail
                    )
                ),
                semantics(X, L),
                conj_list(Y, L)
            )
        )
    ).

'<http://www.w3.org/2000/10/swap/log#semanticsOrError>'(X, Y) :-
    \+flag(restricted),
    when(
        (   nonvar(X)
        ),
        (   (   semantics(X, L)
            ->  conj_list(Y, L)
            ;   sub_atom(X, 0, 1, _, '<'),
                sub_atom(X, _, 1, 0, '>'),
                sub_atom(X, 1, _, 1, Z),
                catch(
                    n3_n3p(Z, semantics),
                    Exc,
                    assertz(semantics(X, [literal(Exc, type('<http://www.w3.org/2001/XMLSchema#string>'))]))
                ),
                semantics(X, L),
                conj_list(Y, L)
            )
        )
    ).

'<http://www.w3.org/2000/10/swap/log#skolem>'(Y, X) :-
    when(
        (   nonvar(X)
        ;   ground(Y)
        ),
        (   (   is_list(Y),
                length(Y, I),
                I < 8
            ->  Z =.. [tuple, X|Y]
            ;   Z = tuple(X, Y)
            ),
            (   call(Z)
            ->  true
            ;   var(X),
                nb_getval(tuple, M),
                N is M+1,
                nb_setval(tuple, N),
                atom_number(A, N),
                nb_getval(var_ns, Sns),
                atomic_list_concat(['<', Sns, 't_', A, '>'], X),
                assertz(Z)
            )
        )
    ),
    (   \+keep_skolem(X)
    ->  assertz(keep_skolem(X))
    ;   true
    ).

'<http://www.w3.org/2000/10/swap/log#trace>'(X, Y) :-
    tell(user_error),
    copy_term_nat(X, U),
    wg(U),
    write(' TRACE '),
    copy_term_nat(Y, V),
    (   number(X),
        X < 0
    ->  fm(V)
    ;   wg(V)
    ),
    nl,
    told,
    (   flag('output', Output)
    ->  tell(Output)
    ;   true
    ).

'<http://www.w3.org/2000/10/swap/log#uri>'(X, Y) :-
    when(
        (   ground(X)
        ;   ground(Y)
        ),
        (   atomic(X),
            X \= [],
            (   atom_concat(some, V, X)
            ->  nb_getval(var_ns, Sns),
                atomic_list_concat(['<', Sns, 'sk_', V, '>'], U)
            ;   (   atom_concat(avar, V, X)
                ->  atomic_list_concat(['<http://www.w3.org/2000/10/swap/var#x_', V, '>'], U)
                ;   U = X
                )
            ),
            sub_atom(U, 1, _, 1, Z),
            atomic_list_concat(['<', Z, '>'], U),
            Y = literal(Z, type('<http://www.w3.org/2001/XMLSchema#string>')),
            !
        ;   ground(Y),
            Y = literal(Z, type('<http://www.w3.org/2001/XMLSchema#string>')),
            atomic_list_concat(['<', Z, '>'], X)
        )
    ).

'<http://www.w3.org/2000/10/swap/log#uuid>'(X, literal(Y, type('<http://www.w3.org/2001/XMLSchema#string>'))) :-
    when(
        (   ground(X)
        ),
        (   '<http://www.w3.org/2000/10/swap/log#uri>'(X, literal(U, type('<http://www.w3.org/2001/XMLSchema#string>'))),
            (   uuid(U, Y)
            ->  true
            ;   uuid(Y),
                assertz(uuid(U, Y))
            )
        )
    ).

'<http://www.w3.org/2000/10/swap/log#version>'(_, literal(V, type('<http://www.w3.org/2001/XMLSchema#string>'))) :-
    version_info(V).

'<http://www.w3.org/2000/10/swap/math#absoluteValue>'(X, Y) :-
    when(
        (   ground(X)
        ),
        (   getnumber(X, U),
            Y is abs(U)
        )
    ).

'<http://www.w3.org/2000/10/swap/math#acos>'(X, Y) :-
    when(
        (   ground(X)
        ;   ground(Y)
        ),
        (   getnumber(X, U),
            Y is acos(U),
            !
        ;   getnumber(Y, V),
            X is cos(V)
        )
    ).

'<http://www.w3.org/2000/10/swap/math#acosh>'(X, Y) :-
    when(
        (   ground(X)
        ;   ground(Y)
        ),
        (   getnumber(X, U),
            Y is acosh(U),
            !
        ;   getnumber(Y, V),
            X is cosh(V)
        )
    ).

'<http://www.w3.org/2000/10/swap/math#asin>'(X, Y) :-
    when(
        (   ground(X)
        ;   ground(Y)
        ),
        (   getnumber(X, U),
            Y is asin(U),
            !
        ;   getnumber(Y, V),
            X is sin(V)
        )
    ).

'<http://www.w3.org/2000/10/swap/math#asinh>'(X, Y) :-
    when(
        (   ground(X)
        ;   ground(Y)
        ),
        (   getnumber(X, U),
            Y is asinh(U),
            !
        ;   getnumber(Y, V),
            X is sinh(V)
        )
    ).

'<http://www.w3.org/2000/10/swap/math#atan>'(X, Y) :-
    when(
        (   ground(X)
        ;   ground(Y)
        ),
        (   getnumber(X, U),
            Y is atan(U),
            !
        ;   getnumber(Y, V),
            X is tan(V)
        )
    ).

'<http://www.w3.org/2000/10/swap/math#atan2>'([X, Y], Z) :-
    when(
        (   ground([X, Y])
        ),
        (   getnumber(X, U),
            getnumber(Y, V),
            Z is atan(U/V)
        )
    ).

'<http://www.w3.org/2000/10/swap/math#atanh>'(X, Y) :-
    when(
        (   ground(X)
        ;   ground(Y)
        ),
        (   getnumber(X, U),
            Y is atanh(U),
            !
        ;   getnumber(Y, V),
            X is tanh(V)
        )
    ).

'<http://www.w3.org/2000/10/swap/math#ceiling>'(X, Y) :-
    when(
        (   ground(X)
        ),
        (   getnumber(X, U),
            Y is ceiling(U)
        )
    ).

'<http://www.w3.org/2000/10/swap/math#cos>'(X, Y) :-
    when(
        (   ground(X)
        ;   ground(Y)
        ),
        (   getnumber(X, U),
            Y is cos(U),
            !
        ;   getnumber(Y, V),
            X is acos(V)
        )
    ).

'<http://www.w3.org/2000/10/swap/math#cosh>'(X, Y) :-
    when(
        (   ground(X)
        ;   ground(Y)
        ),
        (   getnumber(X, U),
            Y is cosh(U),
            !
        ;   getnumber(Y, V),
            X is acosh(V)
        )
    ).

'<http://www.w3.org/2000/10/swap/math#degrees>'(X, Y) :-
    when(
        (   ground(X)
        ;   ground(Y)
        ),
        (   getnumber(X, U),
            Y is U*180/pi,
            !
        ;   getnumber(Y, V),
            X is V*pi/180
        )
    ).

'<http://www.w3.org/2000/10/swap/math#difference>'([X, Y], Z) :-
    when(
        (   ground([X, Y])
        ;   ground(Z)
        ),
        (   getnumber(X, U),
            getnumber(Y, V),
            Z is U-V,
            !
        ;   getnumber(X, U),
            getnumber(Z, W),
            Y is U-W,
            !
        ;   getnumber(Y, V),
            getnumber(Z, W),
            X is V+W
        )
    ).

'<http://www.w3.org/2000/10/swap/math#equalTo>'(X, Y) :-
    when(
        (   ground([X, Y])
        ),
        (   getnumber(X, U),
            getnumber(Y, V),
            U =:= V
        )
    ).

'<http://www.w3.org/2000/10/swap/math#exponentiation>'([X, Y], Z) :-
    when(
        (   ground([X, Y])
        ;   ground([X, Z])
        ),
        (   getnumber(X, U),
            (   getnumber(Y, V),
                Z is U**V,
                !
            ;   getnumber(Z, W),
                W =\= 0,
                U =\= 0,
                Y is log(W)/log(U)
            )
        )
    ).

'<http://www.w3.org/2000/10/swap/math#floor>'(X, Y) :-
    when(
        (   ground(X)
        ),
        (   getnumber(X, U),
            Y is floor(U)
        )
    ).

'<http://www.w3.org/2000/10/swap/math#greaterThan>'(X, Y) :-
    when(
        (   ground([X, Y])
        ),
        (   getnumber(X, U),
            getnumber(Y, V),
            U > V
        )
    ).

'<http://www.w3.org/2000/10/swap/math#integerQuotient>'([X, Y], Z) :-
    when(
        (   ground([X, Y])
        ),
        (   getnumber(X, U),
            getnumber(Y, V),
            (   V =\= 0
            ->  Z is round(floor(U/V))
            ;   throw(zero_division('<http://www.w3.org/2000/10/swap/math#integerQuotient>'([X, Y], Z)))
            )
        )
    ).

'<http://www.w3.org/2000/10/swap/math#lessThan>'(X, Y) :-
    when(
        (   ground([X, Y])
        ),
        (   getnumber(X, U),
            getnumber(Y, V),
            U < V
        )
    ).

'<http://www.w3.org/2000/10/swap/math#logarithm>'([X, Y], Z) :-
    when(
        (   ground([X, Y])
        ;   ground([X, Z])
        ),
        (   getnumber(X, U),
            (   getnumber(Y, V),
                V =\= 0,
                U =\= 0,
                Z is log(U)/log(V),
                !
            ;   getnumber(Z, W),
                Y is U**(1/W)
            )
        )
    ).

'<http://www.w3.org/2000/10/swap/math#max>'(X, Y) :-
    when(
        (   ground(X)
        ),
        (   max_list(X, Y)
        )
    ).

'<http://www.w3.org/2000/10/swap/math#memberCount>'(X, Y) :-
    when(
        (   nonvar(X)
        ),
        (   (   getlist(X, Z)
            ->  true
            ;   conj_list(X, U),
                (   ground(U)
                ->  distinct(U, Z)
                ;   Z = U
                )
            ),
            length(Z, Y)
        )
    ).

'<http://www.w3.org/2000/10/swap/math#min>'(X, Y) :-
    when(
        (   ground(X)
        ),
        (   min_list(X, Y)
        )
    ).

'<http://www.w3.org/2000/10/swap/math#negation>'(X, Y) :-
    when(
        (   ground(X)
        ;   ground(Y)
        ),
        (   getnumber(X, U),
            Y is -U,
            !
        ;   getnumber(Y, V),
            X is -V
        )
    ).

'<http://www.w3.org/2000/10/swap/math#notEqualTo>'(X, Y) :-
    when(
        (   ground([X, Y])
        ),
        (   getnumber(X, U),
            getnumber(Y, V),
            U =\= V
        )
    ).

'<http://www.w3.org/2000/10/swap/math#notGreaterThan>'(X, Y) :-
    when(
        (   ground([X, Y])
        ),
        (   getnumber(X, U),
            getnumber(Y, V),
            U =< V
        )
    ).

'<http://www.w3.org/2000/10/swap/math#notLessThan>'(X, Y) :-
    when(
        (   ground([X, Y])
        ),
        (   getnumber(X, U),
            getnumber(Y, V),
            U >= V
        )
    ).

'<http://www.w3.org/2000/10/swap/math#product>'(X, Y) :-
    when(
        (   ground(X)
        ),
        (   product(X, Y)
        )
    ).

'<http://www.w3.org/2000/10/swap/math#quotient>'([X, Y], Z) :-
    when(
        (   ground([X, Y])
        ;   ground(Z)
        ),
        (   getnumber(X, U),
            getnumber(Y, V),
            (   V =\= 0
            ->  Z is U/V
            ;   throw(zero_division('<http://www.w3.org/2000/10/swap/math#quotient>'([X, Y], Z)))
            ),
            !
        ;   getnumber(X, U),
            getnumber(Z, W),
            (   W =\= 0
            ->  Y is U/W
            ;   throw(zero_division('<http://www.w3.org/2000/10/swap/math#quotient>'([X, Y], Z)))
            ),
            !
        ;   getnumber(Y, V),
            getnumber(Z, W),
            X is V*W
        )
    ).

'<http://www.w3.org/2000/10/swap/math#radians>'(X, Y) :-
    when(
        (   ground(X)
        ;   ground(Y)
        ),
        (   getnumber(X, U),
            Y is U*pi/180,
            !
        ;   getnumber(Y, V),
            X is V*180/pi
        )
    ).

'<http://www.w3.org/2000/10/swap/math#remainder>'([X, Y], Z) :-
    when(
        (   ground([X, Y])
        ),
        (   getnumber(X, U),
            getnumber(Y, V),
            (   V =\= 0
            ->  Z is U-V*round(floor(U/V))
            ;   throw(zero_division('<http://www.w3.org/2000/10/swap/math#remainder>'([X, Y], Z)))
            )
        )
    ).

'<http://www.w3.org/2000/10/swap/math#rounded>'(X, Y) :-
    when(
        (   ground(X)
        ),
        (   getnumber(X, U),
            Y is round(round(U))
        )
    ).

'<http://www.w3.org/2000/10/swap/math#roundedTo>'([X, Y], Z) :-
    when(
        (   ground([X, Y])
        ),
        (   getnumber(X, U),
            getnumber(Y, V),
            F is 10**floor(V),
            Z is round(round(U*F))/F
        )
    ).

'<http://www.w3.org/2000/10/swap/math#sin>'(X, Y) :-
    when(
        (   ground(X)
        ;   ground(Y)
        ),
        (   getnumber(X, U),
            Y is sin(U),
            !
        ;   getnumber(Y, V),
            X is asin(V)
        )
    ).

'<http://www.w3.org/2000/10/swap/math#sinh>'(X, Y) :-
    when(
        (   ground(X)
        ;   ground(Y)
        ),
        (   getnumber(X, U),
            Y is sinh(U),
            !
        ;   getnumber(Y, V),
            X is asinh(V)
        )
    ).

'<http://www.w3.org/2000/10/swap/math#sum>'(X, Y) :-
    when(
        (   ground(X)
        ),
        (   sum(X, Y)
        )
    ).

'<http://www.w3.org/2000/10/swap/math#tan>'(X, Y) :-
    when(
        (   ground(X)
        ;   ground(Y)
        ),
        (   getnumber(X, U),
            Y is tan(U),
            !
        ;   getnumber(Y, V),
            X is atan(V)
        )
    ).

'<http://www.w3.org/2000/10/swap/math#tanh>'(X, Y) :-
    when(
        (   ground(X)
        ;   ground(Y)
        ),
        (   getnumber(X, U),
            Y is tanh(U),
            !
        ;   getnumber(Y, V),
            X is atanh(V)
        )
    ).

'<http://www.w3.org/2000/10/swap/string#capitalize>'(literal(X, Z), literal(Y, Z)) :-
    when(
        (   ground(X)
        ),
        (   sub_atom(X, 0, 1, _, A),
            upcase_atom(A, B),
            sub_atom(X, 1, _, 0, C),
            downcase_atom(C, D),
            atom_concat(B, D, Y)
        )
    ).

'<http://www.w3.org/2000/10/swap/string#concatenation>'(X, Y) :-
    when(
        (   ground(X)
        ),
        (   getlist(X, C),
            labelvars(C, 0, _, avar),
            (   member(D, C),
                var(D),
                var(Y)
            ->  true
            ;   findall(S,
                    (   member(A, X),
                        getcodes(A, S)
                    ),
                    Z
                ),
                flatten(Z, E),
                atom_codes(F, E),
                Y = literal(F, type('<http://www.w3.org/2001/XMLSchema#string>'))
            )
        )
    ).

'<http://www.w3.org/2000/10/swap/string#contains>'(literal(X, Z), literal(Y, Z)) :-
    when(
        (   ground([X, Y])
        ),
        (   sub_atom(X, _, _, _, Y)
        )
    ).

'<http://www.w3.org/2000/10/swap/string#containsIgnoringCase>'(literal(X, Z), literal(Y, Z)) :-
    when(
        (   ground([X, Y])
        ),
        (   downcase_atom(X, U),
            downcase_atom(Y, V),
            sub_atom(U, _, _, _, V)
        )
    ).

'<http://www.w3.org/2000/10/swap/string#containsRoughly>'(literal(X, Z), literal(Y, Z)) :-
    when(
        (   ground([X, Y])
        ),
        (   downcase_atom(X, R),
            downcase_atom(Y, S),
            normalize_space(atom(U), R),
            normalize_space(atom(V), S),
            sub_atom(U, _, _, _, V)
        )
    ).

'<http://www.w3.org/2000/10/swap/string#endsWith>'(literal(X, _), literal(Y, _)) :-
    when(
        (   ground([X, Y])
        ),
        (   sub_atom(X, _, _, 0, Y)
        )
    ).

'<http://www.w3.org/2000/10/swap/string#equalIgnoringCase>'(literal(X, _), literal(Y, _)) :-
    when(
        (   ground([X, Y])
        ),
        (   downcase_atom(X, U),
            downcase_atom(Y, U)
        )
    ).

'<http://www.w3.org/2000/10/swap/string#format>'([literal(A, _)|B], literal(C, type('<http://www.w3.org/2001/XMLSchema#string>'))) :-
    when(
        (   ground([A, B])
        ),
        (   atom_codes(A, D),
            subst([[[0'%, 0's], [0'~, 0'w]]], D, E),
            preformat(B, F),
            format_to_chars(E, F, G),
            atom_codes(C, G)
        )
    ).

'<http://www.w3.org/2000/10/swap/string#greaterThan>'(X, Y) :-
    when(
        (   ground([X, Y])
        ),
        (   getstring(X, U),
            getstring(Y, V),
            U @> V
        )
    ).

'<http://www.w3.org/2000/10/swap/string#join>'([X, Y], Z) :-
    when(
        (   ground([X, Y])
        ;   ground(Z)
        ),
        (   ground([X, Y]),
            getlist(X, C),
            getcodes(Y, D),
            labelvars(C, 0, _, avar),
            (   member(E, C),
                var(E),
                var(Z)
            ->  true
            ;   findall([D, S],
                    (   member(A, X),
                        getcodes(A, S)
                    ),
                    U
                ),
                flatten(U, V),
                (   V = []
                ->  F = V
                ;   append(D, F, V)
                ),
                atom_codes(G, F),
                Z = literal(G, type('<http://www.w3.org/2001/XMLSchema#string>'))
            )
        ;   ground(Z),
            getcodes(Z, U),
            getcodes(Y, C),
            escape_string(T, U),
            escape_string(V, C),
            (   V = []
            ->  findall(literal(A, type('<http://www.w3.org/2001/XMLSchema#string>')),
                    (   member(B, T),
                        atom_codes(A, [B])
                    ),
                    Q
                )
            ;   esplit_string(T, V, [], W),
                findall(literal(A, type('<http://www.w3.org/2001/XMLSchema#string>')),
                    (   member(B, W),
                        atom_codes(A, B)
                    ),
                    Q
                )
            ),
            findall(literal(N, type('<http://www.w3.org/2001/XMLSchema#string>')),
                (   member(literal(M, type('<http://www.w3.org/2001/XMLSchema#string>')), Q),
                    atom_codes(M, Mc),
                    escape_string(Mc, Nc),
                    atom_codes(N, Nc)
                ),
                X
            )
        )
    ).

'<http://www.w3.org/2000/10/swap/string#lessThan>'(X, Y) :-
    when(
        (   ground([X, Y])
        ),
        (   getstring(X, U),
            getstring(Y, V),
            U @< V
        )
    ).

'<http://www.w3.org/2000/10/swap/string#length>'(literal(A, _), B) :-
    when(
        (   ground(A)
        ),
        (   sub_atom(A, 0, B, 0, _)
        )
    ).

'<http://www.w3.org/2000/10/swap/string#lowerCase>'(literal(X, Z), literal(Y, Z)) :-
    when(
        (   ground(X)
        ),
        (   downcase_atom(X, Y)
        )
    ).

'<http://www.w3.org/2000/10/swap/string#matches>'(literal(X, _), literal(Y, _)) :-
    when(
        (   ground([X, Y])
        ),
        (   regex(Y, X, _)
        )
    ).

'<http://www.w3.org/2000/10/swap/string#notContainsRoughly>'(X, Y) :-
    \+'<http://www.w3.org/2000/10/swap/string#containsRoughly>'(X, Y).

'<http://www.w3.org/2000/10/swap/string#notEqualIgnoringCase>'(X, Y) :-
    \+'<http://www.w3.org/2000/10/swap/string#equalIgnoringCase>'(X, Y).

'<http://www.w3.org/2000/10/swap/string#notGreaterThan>'(X, Y) :-
    when(
        (   ground([X, Y])
        ),
        (   getstring(X, U),
            getstring(Y, V),
            U @=< V
        )
    ).

'<http://www.w3.org/2000/10/swap/string#notLessThan>'(X, Y) :-
    when(
        (   ground([X, Y])
        ),
        (   getstring(X, U),
            getstring(Y, V),
            U @>= V
        )
    ).

'<http://www.w3.org/2000/10/swap/string#notMatches>'(X, Y) :-
    \+'<http://www.w3.org/2000/10/swap/string#matches>'(X, Y).

'<http://www.w3.org/2000/10/swap/string#replace>'([literal(X, _), literal(Search, _), literal(Replace, _)], literal(Y, type('<http://www.w3.org/2001/XMLSchema#string>'))) :-
    when(
        (   ground([X, Search, Replace])
        ),
        (   (   atomic_list_concat(['(', Search, ')'], Se),
                regex(Se, X, [S|_])
            ->  (   sub_atom(Search, 0, 1, _, '^')
                ->  atom_concat(S, T, X),
                    atom_concat(Replace, T, Y)
                ;   (   sub_atom(Search, _, 1, 0, '$')
                    ->  atom_concat(T, S, X),
                        atom_concat(T, Replace, Y)
                    ;   atom_codes(X, XC),
                        string_codes(S, SC),
                        atom_codes(Replace, RC),
                        subst([[[0'$, 0'1], SC]], RC, TC),
                        subst([[SC, TC]], XC, YC),
                        atom_codes(Y, YC)
                    )
                )
            ;   Y = X
            )
        )
    ).

'<http://www.w3.org/2000/10/swap/string#replaceAll>'([literal(X, _), SearchList, ReplaceList], literal(Y, type('<http://www.w3.org/2001/XMLSchema#string>'))) :-
    when(
        (   ground([X, SearchList, ReplaceList])
        ),
        (   preformat(SearchList, SearchList2),
            preformat(ReplaceList, ReplaceList2),
            replace(SearchList2, ReplaceList2, X, Z),
            atom_string(Y, Z)
        )
    ).

'<http://www.w3.org/2000/10/swap/string#scrape>'([literal(X, _), literal(Y, _)], literal(Z, type('<http://www.w3.org/2001/XMLSchema#string>'))) :-
    when(
        (   ground([X, Y])
        ),
        (   regex(Y, X, [W|_]),
            atom_string(Z, W)
        )
    ).

'<http://www.w3.org/2000/10/swap/string#scrapeAll>'([literal(X, _), literal(Y, _)], Z) :-
    when(
        (   ground([X, Y])
        ),
        (   scrape(X, Y, V),
            preformat(Z, V)
        )
    ).

'<http://www.w3.org/2000/10/swap/string#search>'([literal(X, _), literal(Y, _)], Z) :-
    when(
        (   ground([X, Y])
        ),
        (   regex(Y, X, L),
            findall(literal(A, type('<http://www.w3.org/2001/XMLSchema#string>')),
                (   member(M, L),
                    atom_string(A, M)
                ),
                Z
            )
        )
    ).

'<http://www.w3.org/2000/10/swap/string#startsWith>'(literal(X, _), literal(Y, _)) :-
    when(
        (   ground([X, Y])
        ),
        (   sub_atom(X, 0, _, _, Y)
        )
    ).

'<http://www.w3.org/2000/10/swap/string#substring>'([literal(A, _), B, C], literal(D, type('<http://www.w3.org/2001/XMLSchema#string>'))) :-
    !,
    when(
        (   ground([A, B, C])
        ),
        (   getint(B, I),
            getint(C, J),
            (   I < 1
            ->  G is 0,
                H is J+I-1
            ;   G is I-1,
                H is J
            ),
            (   H < 0
            ->  D = ''
            ;   sub_atom(A, G, H, _, D)
            )
        )
    ).
'<http://www.w3.org/2000/10/swap/string#substring>'([literal(A, _), B], literal(D, type('<http://www.w3.org/2001/XMLSchema#string>'))) :-
    when(
        (   ground([A, B])
        ),
        (   getint(B, I),
            sub_atom(A, 0, E, 0, _),
            J is E-I+1,
            (   I < 1
            ->  G is 0,
                H is J+I-1
            ;   G is I-1,
                H is J
            ),
            (   H < 0
            ->  D = []
            ;   sub_atom(A, G, H, _, D)
            )
        )
    ).

'<http://www.w3.org/2000/10/swap/string#upperCase>'(literal(X, Z), literal(Y, Z)) :-
    when(
        (   ground(X)
        ),
        (   upcase_atom(X, Y)
        )
    ).

'<http://www.w3.org/2000/10/swap/time#day>'(literal(X, _), literal(Y, type('<http://www.w3.org/2001/XMLSchema#string>'))) :-
    when(
        (   ground(X)
        ),
        (   sub_atom(X, 8, 2, _, Y)
        )
    ).

'<http://www.w3.org/2000/10/swap/time#localTime>'(literal(X, _), literal(Y, type('<http://www.w3.org/2001/XMLSchema#dateTime>'))) :-
    when(
        (   ground(X)
        ),
        (   timestamp(Y)
        )
    ).

'<http://www.w3.org/2000/10/swap/time#month>'(literal(X, _), literal(Y, type('<http://www.w3.org/2001/XMLSchema#string>'))) :-
    when(
        (   ground(X)
        ),
        (   sub_atom(X, 5, 2, _, Y)
        )
    ).

'<http://www.w3.org/2000/10/swap/time#year>'(literal(X, _), literal(Y, type('<http://www.w3.org/2001/XMLSchema#string>'))) :-
    when(
        (   ground(X)
        ),
        (   sub_atom(X, 0, 4, _, Y)
        )
    ).

%
% Support
%

def_pfx('math:', '<http://www.w3.org/2000/10/swap/math#>').
def_pfx('e:', '<http://eulersharp.sourceforge.net/2003/03swap/log-rules#>').
def_pfx('list:', '<http://www.w3.org/2000/10/swap/list#>').
def_pfx('xsd:', '<http://www.w3.org/2001/XMLSchema#>').
def_pfx('log:', '<http://www.w3.org/2000/10/swap/log#>').
def_pfx('r:', '<http://www.w3.org/2000/10/swap/reason#>').
def_pfx('rdfs:', '<http://www.w3.org/2000/01/rdf-schema#>').
def_pfx('time:', '<http://www.w3.org/2000/10/swap/time#>').
def_pfx('rdf:', '<http://www.w3.org/1999/02/22-rdf-syntax-ns#>').
def_pfx('string:', '<http://www.w3.org/2000/10/swap/string#>').
def_pfx('owl:', '<http://www.w3.org/2002/07/owl#>').
def_pfx('n3:', '<http://www.w3.org/2004/06/rei#>').

put_pfx(_, URI) :-
    atomic_list_concat(['<', URI, '>'], U),
    pfx(_, U),
    !.
put_pfx(_, URI) :-
    atomic_list_concat(['<', URI, '>'], U),
    def_pfx(Pf, U),
    \+pfx(Pf, _),
    !,
    assertz(pfx(Pf, U)).
put_pfx(Pf, URI) :-
    atomic_list_concat(['<', URI, '>'], U),
    fresh_pf(Pf, Pff),
    assertz(pfx(Pff, U)).

fresh_pf(Pf, Pfx) :-
    atom_concat(Pf, ':', Pfx),
    \+pfx(Pfx, _),
    !.
fresh_pf(_, Pfx) :-
    gensym(ns, Pfn),
    fresh_pf(Pfn, Pfx).

cnt(A) :-
    nb_getval(A, B),
    C is B+1,
    nb_setval(A, C),
    (   flag('debug-cnt'),
        C mod 10000 =:= 0
    ->  format(user_error, '~w = ~w~n', [A, C]),
        flush_output(user_error)
    ;   true
    ).

cnt(A, I) :-
    nb_getval(A, B),
    C is B+I,
    nb_setval(A, C),
    (   flag('debug-cnt'),
        C mod 10000 =:= 0
    ->  format(user_error, '~w = ~w~n', [A, C]),
        flush_output(user_error)
    ;   true
    ).

within_scope([A, B]) :-
    (   var(B)
    ->  B = 1
    ;   true
    ),
    (   B = 0
    ->  brake
    ;   nb_getval(limit, C),
        (   C < B
        ->  nb_setval(limit, B)
        ;   true
        ),
        recursion(B)
    ),
    nb_getval(scope, A).

exo_pred(exopred(P, S, O), A) :-
    atomic(P),
    !,
    A =.. [P, S, O].
exo_pred(A, A).

exopred(P, S, O) :-
    (   var(P),
        var(S),
        var(O)
    ->  pred(P),
        H =.. [P, S, O],
        clause(H, true)
    ;   (   var(P)
        ->  pred(P)
        ;   atom(P),
            current_predicate(P/2)
        ),
        call(P, S, O)
    ).

exogen :-
    forall(
        (   clause(exopred(P, S, O), Body),
            (   nonvar(S)
            ;   nonvar(O)
            )
        ),
        (   (   var(P)
            ->  pred(P)
            ;   atom(P),
                current_predicate(P/2)
            ),
            Head =.. [P, S, O],
            (   \+clause(Head, Body)
            ->  assertz(Head :- Body)
            ;   true
            )
        )
    ).
exogen.

ucall(A) :-
    (   A = (B, C)
    ->  vcall(B),
        ucall(C)
    ;   vcall(A)
    ).

vcall(A) :-
    (   (   A =.. [_, V, W]
        ;   A = exopred(_, V, W)
        ),
        (   is_gl(V)
        ;   is_gl(W)
        )
    ->  unify(A, B)
    ;   B = A
    ),
    (   B =.. [C, D, E],
        pred(C),
        (   is_gl(D)
        ;   is_gl(E)
        )
    ->  G =.. [C, H, I],
        call(G),
        unify(H, D),
        unify(I, E)
    ;   call(B)
    ).

is_gl(A) :-
    nonvar(A),
    \+is_list(A),
    (   A = (_, _),
        !
    ;   A =.. [F, _, _],
        F \= literal,
        F \= rdiv,
        !
    ;   A = exopred(_, _, _)
    ).

is_graph(true).
is_graph(A) :-
    is_gl(A).

unify(A, B) :-
    nonvar(A),
    A = exopred(P, S, O),
    (   (   nonvar(B)
        ;   nonvar(P)
        )
    ->  (   nonvar(P)
        ->  atom(P)
        ;   true
        ),
        B =.. [P, T, R],
        atom(P),
        unify(S, T),
        unify(O, R)
    ;   B = exopred(P, T, R),
        unify(S, T),
        unify(O, R)
    ),
    !.
unify(A, B) :-
    nonvar(B),
    B = exopred(P, S, O),
    (   (   nonvar(A)
        ;   nonvar(P)
        )
    ->  (   nonvar(P)
        ->  atom(P)
        ;   true
        ),
        A =.. [P, T, R],
        atom(P),
        unify(S, T),
        unify(O, R)
    ;   A = exopred(P, T, R),
        unify(S, T),
        unify(O, R)
    ),
    !.
unify(A, B) :-
    is_list(A),
    !,
    getlist(B, C),
    C = A.
unify(A, B) :-
    is_list(B),
    !,
    getlist(A, C),
    C = B.
unify(A, B) :-
    nonvar(A),
    nonvar(B),
    (   A = (_, _)
    ;   B = (_, _)
    ),
    !,
    conj_list(A, C),
    conj_list(B, D),
    includes(C, D),
    includes(D, C).
unify(A, B) :-
    nonvar(A),
    nonvar(B),
    A =.. [P, S, O],
    B =.. [P, T, R],
    !,
    unify(S, T),
    unify(O, R).
unify(A, A).

conj_list(true, []) :-
    !.
conj_list(A, [A]) :-
    A \= (_, _),
    A \= false,
    !.
conj_list((A, B), [A|C]) :-
    conj_list(B, C).

conj_append(A, true, A) :-
    !.
conj_append((A, B), C, (A, D)) :-
    conj_append(B, C, D),
    !.
conj_append(A, B, (A, B)).

cflat([], []).
cflat([A|B], C) :-
    cflat(B, D),
    copy_term_nat(A, E),
    (   E = (_, _),
        conj_list(E, F)
    ->  append(F, D, C)
    ;   (   E = true
        ->  C = D
        ;   C = [E|D]
        )
    ).

couple([], [], []).
couple([A|B], [C|D], [[A, C]|E]) :-
    couple(B, D, E).

relist([], []).
relist(['<http://www.w3.org/1999/02/22-rdf-syntax-ns#first>'(A, B)|C], D) :-
    !,
    assertz('<http://www.w3.org/1999/02/22-rdf-syntax-ns#first>'(A, B)),
    relist(C, D).
relist(['<http://www.w3.org/1999/02/22-rdf-syntax-ns#rest>'(A, B)|C], D) :-
    !,
    assertz('<http://www.w3.org/1999/02/22-rdf-syntax-ns#rest>'(A, B)),
    relist(C, D).
relist([A|B], [A|C]) :-
    relist(B, C).

includes(_, []) :-
    !.
includes(X, [Y|Z]) :-
    member(U, X),
    unify(U, Y),
    includes(X, Z).

conjoin([X], X) :-
    !.
conjoin([true|Y], Z) :-
    conjoin(Y, Z),
    !.
conjoin([X|Y], Z) :-
    conjoin(Y, U),
    conj_append(X, U, V),
    (   ground(V)
    ->  conj_list(V, A),
        list_to_set(A, B),
        conj_list(Z, B)
    ;   Z = V
    ).

difference([true, _], true) :-
    !.
difference([X, true], X) :-
    !.
difference([X, Y], Z) :-
    conj_list(X, U),
    conj_list(Y, V),
    difference(U, V, W),
    distinct(W, J),
    conj_list(Z, J).

difference([], _, []) :-
    !.
difference([X|Y], U, V) :-
    member(Z, U),
    unify(X, Z),
    !,
    difference(Y, U, V).
difference([X|Y], U, [X|V]) :-
    difference(Y, U, V).

intersect([X], X) :-
    !.
intersect([true|_], true) :-
    !.
intersect([X|Y], Z) :-
    intersect(Y, I),
    conj_list(X, U),
    conj_list(I, V),
    intersect(U, V, W),
    distinct(W, J),
    conj_list(Z, J),
    !.

intersect([], _, []) :-
    !.
intersect([X|Y], U, V) :-
    member(Z, U),
    unify(X, Z),
    V = [X|W],
    intersect(Y, U, W).
intersect([_|Y], U, V) :-
    intersect(Y, U, V).

cartesian([], []).
cartesian([A|B], [C|D]) :-
    member(C, A),
    cartesian(B, D).

distinct(A, B) :-
    (   ground(A)
    ->  distinct_hash(A, B)
    ;   distinct_value(A, B)
    ).

distinct_hash([], []) :-
    (   retract(hash_value(_, _)),
        fail
    ;   true
    ),
    !.
distinct_hash([A|B], C) :-
    term_index(A, D),
    (   hash_value(D, E)
    ->  (   unify(A, E)
        ->  C = F
        ;   C = [A|F]
        )
    ;   assertz(hash_value(D, A)),
        C = [A|F]
    ),
    distinct_hash(B, F).

distinct_value([], []).
distinct_value([A|B], [A|D]) :-
    nonvar(A),
    !,
    del(B, A, E),
    distinct_value(E, D).
distinct_value([_|A], B) :-
    distinct_value(A, B).

del([], _, []).
del([A|B], C, D) :-
    copy_term_nat(A, Ac),
    copy_term_nat(C, Cc),
    unify(Ac, Cc),
    !,
    del(B, C, D).
del([A|B], C, [A|D]) :-
    del(B, C, D).

subst(_, [], []).
subst(A, B, C) :-
    member([D, E], A),
    append(D, F, B),
    !,
    append(E, G, C),
    subst(A, F, G).
subst(A, [B|C], [B|D]) :-
    subst(A, C, D).

replace([], [], X, X) :-
    !.
replace([Search|SearchRest], [Replace|ReplaceRest], X, Y) :-
    atomic_list_concat(['(', Search, ')'], Scap),
    scrape(X, Scap, Scrape),
    atom_codes(Replace, RC),
    srlist(Scrape, RC, Subst),
    atom_codes(X, XC),
    subst(Subst, XC, ZC),
    atom_codes(Z, ZC),
    replace(SearchRest, ReplaceRest, Z, Y).

scrape(X, Y, [V|Z]) :-
    regex(Y, X, [W|_]),
    atom_string(V, W),
    sub_atom(X, _, _, I, V),
    sub_atom(X, _, I, 0, U),
    !,
    scrape(U, Y, Z).
scrape(_, _, []).

srlist([], _, []).
srlist([A|B], C, [[E, C]|D]) :-
    string_codes(A, E),
    srlist(B, C, D).

quicksort([], []).
quicksort([A|B], C) :-
    split(A, B, D, E),
    quicksort(D, F),
    quicksort(E, G),
    append(F, [A|G], C).

split(_, [], [], []).
split(A, [B|C], [B|D], E) :-
    sort([A, B], [B, A]),
    !,
    split(A, C, D, E).
split(A, [B|C], D, [B|E]) :-
    split(A, C, D, E).

zip_list([], [], []).
zip_list([A|B], [C|D], [[E,C]|F]) :-
    (   atom_concat('avar', G, A)
    ->  atomic_list_concat(['<http://www.w3.org/2000/10/swap/var#x_', G, '>'], E)
    ;   E = A
    ),
    zip_list(B, D, F).

sub_list(A, A) :-
    !.
sub_list([A|B], C) :-
    sub_list(B, A, C).

sub_list(A, _, A) :-
    !.
sub_list([A|B], C, [C|D]) :-
    !,
    sub_list(B, A, D).
sub_list([A|B], _, C) :-
    sub_list(B, A, C).

e_transpose([], []).
e_transpose([A|B], C) :-
    e_transpose(A, [A|B], C).

e_transpose([], _, []).
e_transpose([_|A], B, [C|D]) :-
    lists_fr(B, C, E),
    e_transpose(A, E, D).

lists_fr([], [], []).
lists_fr([[A|B]|C], [A|D], [B|E]) :-
    lists_fr(C, D, E).

sum([], 0) :-
    !.
sum([A|B], C) :-
    getnumber(A, X),
    sum(B, D),
    C is X+D.

product([], 1) :-
    !.
product([A|B], C) :-
    getnumber(A, X),
    product(B, D),
    C is X*D.

avg(A, B) :-
    sum(A, As),
    length(A, An),
    B is As/An.

cov([A, B], C) :-
    avg(A, Am),
    avg(B, Bm),
    cov1(A, B, Am, Bm, Cp),
    length(A, An),
    C is Cp/(An-1).

cov1([], [], _, _, 0).
cov1([A|B], [C|D], E, F, G) :-
    cov1(B, D, E, F, H),
    getnumber(A, I),
    getnumber(C, J),
    G is (I-E)*(J-F)+H.

pcc([A, B], C) :-
    avg(A, Am),
    avg(B, Bm),
    cov1(A, B, Am, Bm, Cp),
    std1(A, Am, Ap),
    std1(B, Bm, Bp),
    C is Cp/sqrt(Ap*Bp).

rms(A, B) :-
    rms1(A, Ar),
    length(A, An),
    B is sqrt(Ar/An).

rms1([], 0).
rms1([A|B], C) :-
    rms1(B, D),
    getnumber(A, E),
    C is E^2+D.

std(A, B) :-
    avg(A, Am),
    std1(A, Am, As),
    length(A, An),
    B is sqrt(As/(An-1)).

std1([], _, 0).
std1([A|B], C, D) :-
    std1(B, C, E),
    getnumber(A, F),
    D is (F-C)^2+E.

bmax([A|B], C) :-
    bmax(B, A, C).

bmax([], A, A).
bmax([A|B], C, D) :-
    getnumber(A, X),
    getnumber(C, Y),
    (   X > Y
    ->  bmax(B, A, D)
    ;   bmax(B, C, D)
    ).

bmin([A|B], C) :-
    bmin(B, A, C).

bmin([], A, A).
bmin([A|B], C, D) :-
    getnumber(A, X),
    getnumber(C, Y),
    (   X < Y
    ->  bmin(B, A, D)
    ;   bmin(B, C, D)
    ).

inconsistent(['<http://eulersharp.sourceforge.net/2003/03swap/log-rules#boolean>'(A, '<http://eulersharp.sourceforge.net/2003/03swap/log-rules#T>')|B]) :-
    memberchk('<http://eulersharp.sourceforge.net/2003/03swap/log-rules#boolean>'(A, '<http://eulersharp.sourceforge.net/2003/03swap/log-rules#F>'), B),
    !.
inconsistent(['<http://eulersharp.sourceforge.net/2003/03swap/log-rules#boolean>'(A, '<http://eulersharp.sourceforge.net/2003/03swap/log-rules#F>')|B]) :-
    memberchk('<http://eulersharp.sourceforge.net/2003/03swap/log-rules#boolean>'(A, '<http://eulersharp.sourceforge.net/2003/03swap/log-rules#T>'), B),
    !.
inconsistent([_|B]) :-
    inconsistent(B).

inverse('<http://eulersharp.sourceforge.net/2003/03swap/log-rules#boolean>'(A, '<http://eulersharp.sourceforge.net/2003/03swap/log-rules#T>'),
    '<http://eulersharp.sourceforge.net/2003/03swap/log-rules#boolean>'(A, '<http://eulersharp.sourceforge.net/2003/03swap/log-rules#F>')) :-
    !.
inverse('<http://eulersharp.sourceforge.net/2003/03swap/log-rules#boolean>'(A, '<http://eulersharp.sourceforge.net/2003/03swap/log-rules#F>'),
    '<http://eulersharp.sourceforge.net/2003/03swap/log-rules#boolean>'(A, '<http://eulersharp.sourceforge.net/2003/03swap/log-rules#T>')).

bnet :-
    (   '<http://eulersharp.sourceforge.net/2003/03swap/log-rules#conditional>'([A|B], _),
        sort(B, C),
        findall(Y,
            (   '<http://eulersharp.sourceforge.net/2003/03swap/log-rules#conditional>'([A|X], Y),
                sort(X, C)
            ),
            L
        ),
        sum(L, S),
        length(L, N),
        Z is S/N,
        \+bcnd([A|B], _),
        assertz(bcnd([A|B], Z)),
        inverse(A, D),
        \+bcnd([D|B], _),
        E is 1-Z,
        assertz(bcnd([D|B], E)),
        fail
    ;   bcnd(['<http://eulersharp.sourceforge.net/2003/03swap/log-rules#boolean>'(A, _)|B], _),
        (   \+bvar(A),
            assertz(bvar(A))
        ;   true
        ),
        member('<http://eulersharp.sourceforge.net/2003/03swap/log-rules#boolean>'(C, _), B),
        \+bref(C, A),
        assertz(bref(C, A)),
        \+bvar(C),
        assertz(bvar(C)),
        fail
    ;   true
    ).

bval('<http://eulersharp.sourceforge.net/2003/03swap/log-rules#T>').
bval('<http://eulersharp.sourceforge.net/2003/03swap/log-rules#F>').

brel('<http://eulersharp.sourceforge.net/2003/03swap/log-rules#boolean>'(A, _), '<http://eulersharp.sourceforge.net/2003/03swap/log-rules#boolean>'(B, _)) :-
    bref(A, B),
    !.
brel(A, '<http://eulersharp.sourceforge.net/2003/03swap/log-rules#boolean>'(B, _)) :-
    bref(C, B),
    brel(A, '<http://eulersharp.sourceforge.net/2003/03swap/log-rules#boolean>'(C, _)).

bpar([], []) :-
    !.
bpar(['<http://eulersharp.sourceforge.net/2003/03swap/log-rules#boolean>'(A, _)|B], [A|C]) :-
    bpar(B, C).

bget(A, B, 1.0) :-
    memberchk(A, B),
    !.
bget('<http://eulersharp.sourceforge.net/2003/03swap/log-rules#boolean>'(A, '<http://eulersharp.sourceforge.net/2003/03swap/log-rules#T>'), B, 0.0) :-
    memberchk('<http://eulersharp.sourceforge.net/2003/03swap/log-rules#boolean>'(A, '<http://eulersharp.sourceforge.net/2003/03swap/log-rules#F>'), B),
    !.
bget('<http://eulersharp.sourceforge.net/2003/03swap/log-rules#boolean>'(A, '<http://eulersharp.sourceforge.net/2003/03swap/log-rules#F>'), B, C) :-
    (   memberchk('<http://eulersharp.sourceforge.net/2003/03swap/log-rules#boolean>'(A, '<http://eulersharp.sourceforge.net/2003/03swap/log-rules#T>'), B),
        !,
        C is 0.0
    ;
        !,
        bget('<http://eulersharp.sourceforge.net/2003/03swap/log-rules#boolean>'(A, '<http://eulersharp.sourceforge.net/2003/03swap/log-rules#T>'), B, D),
        C is 1-D
    ).
bget(A, B, C) :-
    (   bgot(A, B, C)
    ->  true
    ;   (   member(X, B),
            brel(A, X),
            member(G, B),
            findall(_,
                (   member(Z, [A|B]),
                    brel(G, Z)
                ),
                []
            ),
            del(B, G, H),
            !,
            bget(G, [A|H], U),
            bget(A, H, V),
            bget(G, H, W),
            (   W < 1e-15
            ->  C is 0.5
            ;   E is U*V/W,
                bmin([E, 1.0], C)
            )
        ;   findall([Z, Y],
                (   bcnd([A|O], P),
                    bcon(O, B, Q),
                    Z is P*Q,
                    bpar(O, Y)
                ),
                L
            ),
            findall(Z,
                (   member([_, Z], L)
                ),
                N
            ),
            distinct(N, I),
            findall(Z,
                (   member(Y, I),
                    findall(P,
                        (   member([P, Y], L)
                        ),
                        Q
                    ),
                    sum(Q, R),
                    length(Q, S),
                    length(Y, T),
                    (   Q = []
                    ->  Z is 0.0
                    ;   D is 2**(T-ceiling(log(S)/log(2))),
                        (   D < 1
                        ->  Z is R*D
                        ;   Z is R
                        )
                    )
                ),
                J
            ),
            (   J = []
            ->  C is 0.0
            ;   bmax(J, C)
            )
        ),
        assertz(bgot(A, B, C))
    ).

bcon([], _, 1.0) :-
    !.
bcon(_, B, 0.5) :-
    inconsistent(B),
    !.
bcon([A|B], C, D) :-
    bget(A, C, E),
    bcon(B, [A|C], F),
    D is E*F.

tmp_file(A) :-
    (   current_prolog_flag(dialect, swi),
        current_prolog_flag(windows, true),
        current_prolog_flag(pid, B)
    ->  atomic_list_concat(['pl_eye_', B, '_'], C)
    ;   C = 'eye'
    ),
    tmp_file(C, A).

exec(A, B) :-
    shell(A, B),
    (   B =:= 0
    ->  true
    ;   throw(exec_error(A))
    ).

getcwd(A) :-
    working_directory(A, A).

%
% Modified Base64 for XML identifiers
%

base64xml(A, B) :-
    base64(A, C),
    atom_codes(C, D),
    subst([[[0'+], [0'_]], [[0'/], [0':]], [[0'=], []]], D, E),
    atom_codes(B, E).

term_index(A, B) :-
    term_hash(A, B).

if_then_else(A, B, C) :-
    (   catch(call(A), _, fail)
    ->  catch(call(B), _, fail)
    ;   catch(call(C), _, fail)
    ).

soft_cut(A, B, C) :-
    (   catch(call(A), _, fail)
    *-> catch(call(B), _, fail)
    ;   catch(call(C), _, fail)
    ).

inv(false, true).
inv(true, false).

+(A, B, C) :-
    plus(A, B, C).

':-'(A, B) :-
    (   var(A)
    ->  cpred(C),
        A =.. [C, _, _]
    ;   true
    ),
    (   A = exopred(P, S, O)
    ->  Ax =.. [P, S, O]
    ;   Ax = A
    ),
    clause(Ax, D),
    (   \+flag(nope),
        (   D = when(H, I)
        ->  conj_append(J, istep(Src, _, _, _), I),
            B = when(H, J)
        ;   conj_append(B, istep(Src, _, _, _), D)
        )
    ->  term_index(true, Pnd),
        (   \+prfstep(':-'(Ax, B), true, Pnd, ':-'(Ax, B), _, forward, Src)
        ->  assertz(prfstep(':-'(Ax, B), true, Pnd, ':-'(Ax, B), _, forward, Src))
        ;   true
        )
    ;   D = B
    ).

sub_atom_last(A, B, C, D, E) :-
    sub_atom(A, B, C, D, E),
    F is B+1,
    sub_atom(A, F, _, 0, G),
    (   sub_atom(G, _, C, _, E)
    ->  sub_atom_last(G, B, C, D, E)
    ;   true
    ).

lookup(A, B, C) :-
    tabl(A, B, C),
    !.
lookup(A, B, C) :-
    var(A),
    nb_getval(tabl, M),
    N is M+1,
    nb_setval(tabl, N),
    atom_number(I, N),
    atomic_list_concat([B, '_tabl_entry_', I], A),
    assertz(tabl(A, B, C)).

escape_string([], []) :-
    !.
escape_string([0'\t|A], [0'\\, 0't|B]) :-
    !,
    escape_string(A, B).
escape_string([0'\b|A], [0'\\, 0'b|B]) :-
    !,
    escape_string(A, B).
escape_string([0'\n|A], [0'\\, 0'n|B]) :-
    !,
    escape_string(A, B).
escape_string([0'\r|A], [0'\\, 0'r|B]) :-
    !,
    escape_string(A, B).
escape_string([0'\f|A], [0'\\, 0'f|B]) :-
    !,
    escape_string(A, B).
escape_string([0'"|A], [0'\\, 0'"|B]) :-
    !,
    escape_string(A, B).
escape_string([0'\\|A], [0'\\, 0'\\|B]) :-
    !,
    escape_string(A, B).
escape_string([A|B], [A|C]) :-
    escape_string(B, C).

escape_squote([], []) :-
    !.
escape_squote([0''|A], [0'\\, 0''|B]) :-
    !,
    escape_squote(A, B).
escape_squote([A|B], [A|C]) :-
    escape_squote(B, C).

escape_unicode([], []) :-
    !.
escape_unicode([A, B|C], D) :-
    0xD800 =< A,
    A =< 0xDBFF,
    0xDC00 =< B,
    B =< 0xDFFF,
    E is 0x10000+(A-0xD800)*0x400+(B-0xDC00),
    (   0x100000 =< E
    ->  with_output_to(codes(F), format('\\U00~16R', [E]))
    ;   with_output_to(codes(F), format('\\U000~16R', [E]))
    ),
    append(F, G, D),
    !,
    escape_unicode(C, G).
escape_unicode([A|B], [A|C]) :-
    escape_unicode(B, C).

esplit_string([], _, [], []) :-
    !.
esplit_string([], _, A, [A]) :-
    !.
esplit_string([A|B], C, [], D) :-
    memberchk(A, C),
    !,
    esplit_string(B, C, [], D).
esplit_string([A|B], C, D, [D|E]) :-
    memberchk(A, C),
    !,
    esplit_string(B, C, [], E).
esplit_string([A|B], C, D, E) :-
    append(D, [A], F),
    esplit_string(B, C, F, E).

quant(A, some) :-
    var(A),
    !.
quant('<http://www.w3.org/2000/10/swap/log#implies>'(_, _), allv) :-
    !.
quant(':-'(_, _), allv) :-
    !.
quant(answer('<http://www.w3.org/2000/10/swap/log#implies>', _, _), allv) :-
    !.
quant(answer(':-', _, _), allv) :-
    !.
quant(answer('<http://eulersharp.sourceforge.net/2003/03swap/log-rules#tactic>', _, _), allv) :-
    !.
quant(_-A, avar) :-
    conj_list(A, B),
    member('<http://www.w3.org/2000/10/swap/lingua#premise>'(_, _), B),
    !.
quant(_, some).

labelvars(A, B, C) :-
    quant(A, Q),
    labelvars(A, B, C, Q).

labelvars(A, B, C, D) :-
    var(A),
    !,
    atom_number(E, B),
    atomic_list_concat([D, E], A),      % failing when A is an attributed variable
    C is B+1.
labelvars(A, B, B, _) :-
    atomic(A),
    !.
labelvars('<http://www.w3.org/2000/10/swap/log#implies>'(A, B), C, C, D) :-
    D \= avar,
    nonvar(A),
    nonvar(B),
    !.
labelvars((A, B), C, D, Q) :-
    !,
    labelvars(A, C, E, Q),
    labelvars(B, E, D, Q).
labelvars([A|B], C, D, Q) :-
    !,
    labelvars(A, C, E, Q),
    labelvars(B, E, D, Q).
labelvars(A, B, C, Q) :-
    nonvar(A),
    functor(A, _, D),
    labelvars(0, D, A, B, C, Q).

labelvars(A, A, _, B, B, _) :-
    !.
labelvars(A, B, C, D, E, Q) :-
    F is A+1,
    arg(F, C, G),
    labelvars(G, D, H, Q),
    labelvars(F, B, C, H, E, Q).

relabel(A, A) :-
    var(A),
    !,
    nb_getval(wn, W),
    labelvars(A, W, N, allv),
    nb_setval(wn, N).
relabel([], []) :-
    !.
relabel([A|B], [C|D]) :-
    !,
    relabel(A, C),
    relabel(B, D).
relabel(A, B) :-
    atom(A),
    !,
    (   '<http://eulersharp.sourceforge.net/2003/03swap/log-rules#relabel>'(A, B)
    ->  labelvars(B, 0, _)
    ;   B = A
    ).
relabel(A, A) :-
    number(A),
    !.
relabel(A, B) :-
    A =.. [C|D],
    relabel(C, E),
    relabel(D, F),
    B =.. [E|F].

dynify(A) :-
    var(A),
    !.
dynify(A) :-
    atomic(A),
    !.
dynify([]) :-
    !.
dynify([A|B]) :-
    !,
    dynify(A),
    dynify(B).
dynify(A) :-
    A =.. [B|C],
    length(C, N),
    (   current_predicate(B/N)
    ->  true
    ;   dynamic(B/N)
    ),
    dynify(C).

conjify((A, B), (C, D)) :-
    !,
    conjify(A, C),
    conjify(B, D).
conjify('<http://eulersharp.sourceforge.net/2003/03swap/log-rules#derive>'([literal(when, type('<http://www.w3.org/2001/XMLSchema#string>')),
        '<http://eulersharp.sourceforge.net/2003/03swap/log-rules#derive>'([literal(A, type('<http://www.w3.org/2001/XMLSchema#string>'))|B], true), C], true), when(D, C)) :-
    !,
    D =.. [A|B].
conjify('<http://eulersharp.sourceforge.net/2003/03swap/prolog#cut>'([], true), !) :-
    !.
conjify('<http://eulersharp.sourceforge.net/2003/03swap/log-rules#derive>'([literal(!, type('<http://www.w3.org/2001/XMLSchema#string>'))], true), !) :-
    !.
conjify('<http://www.w3.org/2000/10/swap/log#callWithCut>'(A, _), (A, !)) :-
    !.
conjify(A, A).

atomify(A, A) :-
    var(A),
    !.
atomify([A|B], [C|D]) :-
    !,
    atomify(A, C),
    atomify(B, D).
atomify(literal(A, type('<http://www.w3.org/2001/XMLSchema#string>')), A) :-
    atom(A),
    !.
atomify(A, A).

commonvars('<http://eulersharp.sourceforge.net/2003/03swap/log-rules#transaction>'(A, _), B, C) :-
    !,
    commonvars(A, B, C).
commonvars(A, B, C) :-
    term_variables(A, D),
    term_variables(B, E),
    copy_term_nat([D, E], [F, G]),
    labelvars([F, G], 0, _),
    findall(H,
        (   member(H, F),
            member(H, G)
        ),
        C
    ).

getvars(A, B) :-
    findvars(A, C, alpha),
    distinct(C, B).

makeblank(A, B) :-
    findvars(A, C, beta),
    distinct(C, D),
    findall([F, E],
        (   member(F, D),
            (   sub_atom(F, _, 19, _, '/.well-known/genid/'),
                sub_atom(F, _, 1, G, '#')
            ->  H is G-1,
                sub_atom(F, _, H, 1, I),
                (   sub_atom(F, _, 3, _, '#t_')
                ->  E = F
                ;   atom_concat('_:', I, E)
                )
            ;   (   sub_atom(F, 0, 2, _, '_:')
                ->  E = F
                ;   atom_concat('_:', F, E)
                )
            )
        ),
        J
    ),
    makevar(A, B, J).

makevars(A, B, beta(C)) :-
    !,
    distinct(C, D),
    findvars(A, Z, zeta),
    append(D, Z, E),
    findall([X, _],
        (   member(X, E)
        ),
        F
    ),
    makevar(A, B, F).
makevars(A, B, Z) :-
    findvars(A, C, Z),
    distinct(C, D),
    findall([X, _],
        (   member(X, D)
        ),
        F
    ),
    makevar(A, B, F).

makevar(A, B, D) :-
    atomic(A),
    !,
    (   atom(A),
        member([A, B], D)
    ->  true
    ;   B = A
    ).
makevar(A, A, _) :-
    var(A),
    !.
makevar([], [], _) :-
    !.
makevar([A|B], [C|D], F) :-
    makevar(A, C, F),
    makevar(B, D, F),
    !.
makevar(A, B, F) :-
    A =.. C,
    makevar(C, [Dh|Dt], F),
    (   nonvar(Dh)
    ->  B =.. [Dh|Dt]
    ;   Dt = [Ds, Do],
        B = exopred(Dh, Ds, Do)
    ).

findvars(A, B, Z) :-
    atomic(A),
    !,
    (   atom(A),
        findvar(A, Z)
    ->  B = [A]
    ;   B = []
    ).
findvars(A, [], _) :-
    var(A),
    !.
findvars([], [], _) :-
    !.
findvars([A|B], C, Z) :-
    !,
    findvars(A, D, Z),
    findvars(B, E, Z),
    append(D, E, C).
findvars(A, B, Z) :-
    A =.. C,
    findvars(C, B, Z).

shallowvars(A, B, Z) :-
    atomic(A),
    !,
    (   atom(A),
        findvar(A, Z)
    ->  B = [A]
    ;   B = []
    ).
shallowvars(A, [], _) :-
    var(A),
    !.
shallowvars([], [], _) :-
    !.
shallowvars([A|B], C, Z) :-
    shallowvars(A, D, Z),
    shallowvars(B, E, Z),
    append(D, E, C),
    !.
shallowvars(_, [], _).

findvar(A, alpha) :-
    !,
    (   atom_concat('<http://www.w3.org/2000/10/swap/var#', _, A)
    ;   sub_atom(A, 0, _, _, avar)
    ).
findvar(A, beta) :-
    !,
    (   sub_atom(A, 0, _, _, '_bn_')
    ;   sub_atom(A, 0, _, _, '_e_')
    ;   sub_atom(A, _, 4, _, '#qe_')
    ;   sub_atom(A, _, 19, _, '/.well-known/genid/')
    ;   sub_atom(A, 0, _, _, some)
    ;   sub_atom(A, 0, _, _, '_:')
    ).
findvar(A, delta) :-
    !,
    (   sub_atom(A, _, 19, _, '/.well-known/genid/')
    ;   sub_atom(A, 0, _, _, some)
    ).
findvar(A, epsilon) :-
    !,
    sub_atom(A, 0, 1, _, '_'),
    \+ sub_atom(A, 0, _, _, '_bn_'),
    \+ sub_atom(A, 0, _, _, '_e_').
findvar(A, zeta) :-
    !,
    (   sub_atom(A, _, 19, _, '/.well-known/genid/'),
        (   sub_atom(A, _, 4, _, '#bn_')
        ;   sub_atom(A, _, 4, _, '#e_')
        )
    ;   sub_atom(A, 0, _, _, some)
    ;   sub_atom(A, 0, _, _, avar)
    ).
findvar(A, eta) :-
    sub_atom(A, 0, _, _, allv).

raw_type(A, '<http://www.w3.org/2000/10/swap/log#ForAll>') :-
    var(A),
    !.
raw_type(A, '<http://www.w3.org/1999/02/22-rdf-syntax-ns#List>') :-
    is_list(A),
    !.
raw_type(A, '<http://www.w3.org/2000/10/swap/log#Literal>') :-
    number(A),
    !.
raw_type(true, '<http://www.w3.org/2000/10/swap/log#Formula>').
raw_type(false, '<http://www.w3.org/2000/10/swap/log#Formula>').
raw_type(A, '<http://www.w3.org/2000/10/swap/log#Literal>') :-
    atom(A),
    \+ sub_atom(A, 0, _, _, some),
    \+ sub_atom(A, 0, _, _, avar),
    \+ (sub_atom(A, 0, 1, _, '<'), sub_atom(A, _, 1, 0, '>')),
    !.
raw_type(literal(_, _), '<http://www.w3.org/2000/10/swap/log#Literal>') :-
    !.
raw_type(rdiv(_, _), '<http://www.w3.org/2000/10/swap/log#Literal>') :-
    !.
raw_type('<http://eulersharp.sourceforge.net/2003/03swap/log-rules#epsilon>', '<http://www.w3.org/2000/10/swap/log#Literal>') :-
    !.
raw_type((_, _), '<http://www.w3.org/2000/10/swap/log#Formula>') :-
    !.
raw_type(set(_), '<http://www.w3.org/2000/10/swap/log#Set>') :-
    !.
raw_type(A, '<http://www.w3.org/2000/10/swap/log#Formula>') :-
    functor(A, B, C),
    B \= ':',
    C >= 2,
    !.
raw_type(A, '<http://www.w3.org/2000/10/swap/log#UnlabeledBlankNode>') :-
    nb_getval(var_ns, B),
    sub_atom(A, 1, _, _, B),
    sub_atom(A, _, 4, _, '#bn_'),
    !.
raw_type(A, '<http://www.w3.org/2000/10/swap/log#LabeledBlankNode>') :-
    nb_getval(var_ns, B),
    sub_atom(A, 1, _, _, B),
    sub_atom(A, _, 3, _, '#e_'),
    !.
raw_type(A, '<http://www.w3.org/2000/10/swap/log#SkolemIRI>') :-
    sub_atom(A, _, 19, _, '/.well-known/genid/'),
    !.
raw_type(A, '<http://www.w3.org/2000/10/swap/log#ForSome>') :-
    sub_atom(A, 1, _, _, 'http://www.w3.org/2000/10/swap/var#qe_'),
    !.
raw_type(_, '<http://www.w3.org/2000/10/swap/log#Other>').

getnumber(rdiv(A, B), C) :-
    nonvar(A),
    !,
    C is A/B.
getnumber(A, A) :-
    number(A),
    !.
getnumber(A, epsilon) :-
    nonvar(A),
    A = '<http://eulersharp.sourceforge.net/2003/03swap/log-rules#epsilon>',
    !.
getnumber(A, A) :-
    nonvar(A),
    memberchk(A, [inf, -inf, nan]),
    !.
getnumber(literal(A, type('<http://www.w3.org/2001/XMLSchema#dateTime>')), B) :-
    !,
    ground(A),
    atom_codes(A, C),
    datetime(B, C, []).
getnumber(literal(A, type('<http://www.w3.org/2001/XMLSchema#date>')), B) :-
    !,
    ground(A),
    atom_codes(A, C),
    date(B, C, []).
getnumber(literal(A, type('<http://www.w3.org/2001/XMLSchema#time>')), B) :-
    !,
    ground(A),
    atom_codes(A, C),
    time(B, C, []).
getnumber(literal(A, type('<http://www.w3.org/2001/XMLSchema#duration>')), B) :-
    !,
    ground(A),
    atom_codes(A, C),
    duration(B, C, []).
getnumber(literal(A, type('<http://www.w3.org/2001/XMLSchema#yearMonthDuration>')), B) :-
    !,
    ground(A),
    atom_codes(A, C),
    yearmonthduration(B, C, []).
getnumber(literal(A, type('<http://www.w3.org/2001/XMLSchema#dayTimeDuration>')), B) :-
    !,
    ground(A),
    atom_codes(A, C),
    daytimeduration(B, C, []).
getnumber(literal(A, _), B) :-
    ground(A),
    atom_codes(A, C),
    numeral(C, D),
    catch(number_codes(B, D), _, fail).

getint(A, B) :-
    getnumber(A, C),
    B is integer(round(C)).

getbool(literal(false, type('<http://www.w3.org/2001/XMLSchema#boolean>')), false).
getbool(literal(true, type('<http://www.w3.org/2001/XMLSchema#boolean>')), true).
getbool(literal('0', type('<http://www.w3.org/2001/XMLSchema#boolean>')), false).
getbool(literal('1', type('<http://www.w3.org/2001/XMLSchema#boolean>')), true).
getbool(false, false).
getbool(true, true).

getlist(A, A) :-
    var(A),
    !.
getlist(set(A), A) :-
    !.
getlist([], []) :-
    !.
getlist([A|B], [C|D]) :-
    getlist(A, C),
    !,
    getlist(B, D).
getlist([A|B], [A|D]) :-
    !,
    getlist(B, D).
getlist(A, [B|C]) :-
    '<http://www.w3.org/1999/02/22-rdf-syntax-ns#first>'(A, B),
    (   '<http://www.w3.org/1999/02/22-rdf-syntax-ns#first>'(A, B2),
        B2 \= B
    ->  throw(malformed_list_extra_first(A, B, B2))
    ;   true
    ),
    (   '<http://www.w3.org/1999/02/22-rdf-syntax-ns#rest>'(A, D),
        (   '<http://www.w3.org/1999/02/22-rdf-syntax-ns#rest>'(A, D2),
            D2 \= D
        ->  throw(malformed_list_extra_rest(A, D, D2))
        ;   true
        )
    ->  true
    ;   throw(malformed_list_no_rest(A))
    ),
    (   getlist(D, C)
    ->  true
    ;   throw(malformed_list_invalid_rest(D))
    ).

getterm(A, A) :-
    var(A),
    !.
getterm([], []) :-
    !.
getterm('<http://www.w3.org/1999/02/22-rdf-syntax-ns#nil>', []) :-
    !.
getterm([A|B], [C|D]) :-
    getterm(A, C),
    !,
    getterm(B, D).
getterm(A, [B|C]) :-
    '<http://www.w3.org/1999/02/22-rdf-syntax-ns#first>'(A, D),
    (   '<http://www.w3.org/1999/02/22-rdf-syntax-ns#first>'(A, D2),
        D2 \= D
    ->  throw(malformed_list_extra_first(A, D, D2))
    ;   true
    ),
    (   '<http://www.w3.org/1999/02/22-rdf-syntax-ns#rest>'(A, E),
        (   '<http://www.w3.org/1999/02/22-rdf-syntax-ns#rest>'(A, E2),
            E2 \= E
        ->  throw(malformed_list_extra_rest(A, E, E2))
        ;   true
        )
    ->  true
    ;   throw(malformed_list_no_rest(A))
    ),
    !,
    getterm(D, B),
    (   getterm(E, C),
        is_list(C)
    ->  true
    ;   throw(malformed_list_invalid_rest(E))
    ).
getterm(graph(A, B), graph(A, C)) :-
    graph(A, B),
    !,
    getterm(B, D),
    conjify(D, C).
getterm(graph(A, B), '<http://www.w3.org/2000/10/swap/log#equalTo>'(B, C)) :-
    getconj(A, D),
    D \= A,
    !,
    getterm(D, E),
    conjify(E, C).
getterm(A, B) :-
    graph(A, _),
    !,
    getconj(A, C),
    getterm(C, D),
    conjify(D, B).
getterm(A, B) :-
    A =.. [C|D],
    getterm(D, E),
    B =.. [C|E].

getconj(A, B) :-
    nonvar(A),
    findall(C,
        (   graph(A, C)
        ),
        D
    ),
    D \= [],
    !,
    conjoin(D, B).
getconj(A, A).

getstring(A, B) :-
    '<http://www.w3.org/2000/10/swap/log#uri>'(A, B),
    !.
getstring(A, A).

getcodes(literal(A, _), B) :-
    nonvar(A),
    !,
    atom_codes(A, B).
getcodes(A, B) :-
    nonvar(A),
    with_output_to_chars(wg(A), B).

map(_, [], []) :-
    !.
map(A, [B|C], [D|E]) :-
    F =.. [A, B, D],
    call(F),
    map(A, C, E).

remember(A) :-
    \+call(A),
    !,
    assertz(A).
remember(_).

preformat([], []) :-
    !.
preformat([literal(A, type('<http://www.w3.org/2001/XMLSchema#string>'))|B], [A|D]) :-
    !,
    preformat(B, D).
preformat([A|B], [A|D]) :-
    preformat(B, D).

numeral([0'-, 0'.|A], [0'-, 0'0, 0'.|A]) :-
    !.
numeral([0'+, 0'.|A], [0'+, 0'0, 0'.|A]) :-
    !.
numeral([0'.|A], [0'0, 0'.|A]) :-
    !.
numeral(A, B) :-
    append([C, [0'., 0'e], D], A),
    append([C, [0'., 0'0, 0'e], D], B),
    !.
numeral(A, B) :-
    append([C, [0'., 0'E], D], A),
    append([C, [0'., 0'0, 0'E], D], B),
    !.
numeral(A, B) :-
    last(A, 0'.),
    append(A, [0'0], B),
    !.
numeral(A, A).

rdiv_codes(rdiv(A, B), C) :-
    append(D, [0'.|E], C),
    append(D, E, F),
    number_codes(A, F),
    lzero(E, G),
    number_codes(B, [0'1|G]),
    !.
rdiv_codes(rdiv(A, 1), C) :-
    number_codes(A, C).

lzero([], []) :-
    !.
lzero([_|A], [0'0|B]) :-
    lzero(A, B).

dtlit([literal(A, type('<http://www.w3.org/2001/XMLSchema#string>')), C], B) :-
    nonvar(C),
    '<http://www.w3.org/2000/01/rdf-schema#subClassOf>'(C, '<http://www.w3.org/2001/XMLSchema#integer>'),
    integer(B),
    !,
    atom_number(A, B).
dtlit([literal(A, type('<http://www.w3.org/2001/XMLSchema#string>')), '<http://www.w3.org/2001/XMLSchema#integer>'], B) :-
    integer(B),
    !,
    atom_number(A, B).
dtlit([literal(A, type('<http://www.w3.org/2001/XMLSchema#string>')), '<http://www.w3.org/2001/XMLSchema#double>'], B) :-
    float(B),
    !,
    atom_number(A, B).
dtlit([literal(A, type('<http://www.w3.org/2001/XMLSchema#string>')), '<http://www.w3.org/2001/XMLSchema#dateTime>'], B) :-
    (   number(B)
    ->  datetime(B, C)
    ;   nonvar(B),
        B = date(Year, Month, Day, Hour, Minute, Second, Offset, _, _),
        datetime(Year, Month, Day, Hour, Minute, Second, Offset, C)
    ),
    !,
    atom_codes(A, C).
dtlit([literal(A, type('<http://www.w3.org/2001/XMLSchema#string>')), '<http://www.w3.org/2001/XMLSchema#date>'], B) :-
    (   number(B)
    ->  date(B, C)
    ;   nonvar(B),
        B = date(Year, Month, Day, _, _, _, Offset, _, _),
        date(Year, Month, Day, Offset, C)
    ),
    !,
    atom_codes(A, C).
dtlit([literal(A, type('<http://www.w3.org/2001/XMLSchema#string>')), '<http://www.w3.org/2001/XMLSchema#time>'], B) :-
    (   number(B)
    ->  time(B, C)
    ;   nonvar(B),
        B = date(_, _, _, Hour, Minute, Second, Offset, _, _),
        time(Hour, Minute, Second, Offset, C)
    ),
    !,
    atom_codes(A, C).
dtlit([literal(A, type('<http://www.w3.org/2001/XMLSchema#string>')), '<http://www.w3.org/2001/XMLSchema#duration>'], B) :-
    number(B),
    !,
    daytimeduration(B, C),
    atom_codes(A, C).
dtlit([literal(A, type('<http://www.w3.org/2001/XMLSchema#string>')), '<http://www.w3.org/2001/XMLSchema#yearMonthDuration>'], B) :-
    number(B),
    !,
    yearmonthduration(B, C),
    atom_codes(A, C).
dtlit([literal(A, type('<http://www.w3.org/2001/XMLSchema#string>')), '<http://www.w3.org/2001/XMLSchema#dayTimeDuration>'], B) :-
    number(B),
    !,
    daytimeduration(B, C),
    atom_codes(A, C).
dtlit([literal(A, type('<http://www.w3.org/2001/XMLSchema#string>')), '<http://www.w3.org/2001/XMLSchema#boolean>'], A) :-
    atomic(A),
    getbool(A, A),
    !.
dtlit([literal(A, type('<http://www.w3.org/2001/XMLSchema#string>')), prolog:atom], A) :-
    atomic(A),
    \+ (sub_atom(A, 0, 1, _, '<'), sub_atom(A, _, 1, 0, '>')),
    !.
dtlit([literal(A, type('<http://www.w3.org/2001/XMLSchema#string>')), '<http://www.w3.org/1999/02/22-rdf-syntax-ns#langString>'], literal(A, lang(_))) :-
    !.
dtlit([literal(A, type('<http://www.w3.org/2001/XMLSchema#string>')), B], literal(A, type(B))).

hash_to_ascii([], L1, L1).
hash_to_ascii([A|B], [C, D|L3], L4) :-
    E is A>>4 /\ 15,
    F is A /\ 15,
    code_type(C, xdigit(E)),
    code_type(D, xdigit(F)),
    hash_to_ascii(B, L3, L4).

memotime(datime(A, B, C, D, E, F), G) :-
    (   mtime(datime(A, B, C, D, E, F), G)
    ->  true
    ;   catch(date_time_stamp(date(A, B, C, D, E, F, 0, -, -), H), _, fail),
        fmsec(F, H, G),
        assertz(mtime(datime(A, B, C, D, E, F), G))
    ).

datetime(A, L1, L13) :-
    int(B, L1, [0'-|L3]),
    int(C, L3, [0'-|L5]),
    int(D, L5, [0'T|L7]),
    int(E, L7, [0':|L9]),
    int(F, L9, [0':|L11]),
    decimal(G, L11, L12),
    timezone(H, L12, L13),
    I is -H,
    catch(date_time_stamp(date(B, C, D, E, F, G, I, -, -), J), _, fail),
    fmsec(G, J, A).

datetime(A, B, C, D, E, F, G, L1, L13) :-
    int(A, L1, [0'-|L3]),
    int(B, L3, [0'-|L5]),
    int(C, L5, [0'T|L7]),
    int(D, L7, [0':|L9]),
    int(E, L9, [0':|L11]),
    decimal(F, L11, L12),
    timezone(G, L12, L13).

date(A, L1, L7) :-
    int(B, L1, [0'-|L3]),
    int(C, L3, [0'-|L5]),
    int(D, L5, L6),
    timezone(H, L6, L7),
    I is -H,
    catch(date_time_stamp(date(B, C, D, 0, 0, 0, I, -, -), E), _, fail),
    fmsec(0, E, A).

date(A, B, C, D, L1, L7) :-
    int(A, L1, [0'-|L3]),
    int(B, L3, [0'-|L5]),
    int(C, L5, L6),
    timezone(D, L6, L7).

time(A, L1, L7) :-
    int(B, L1, [0':|L3]),
    int(C, L3, [0':|L5]),
    decimal(D, L5, L6),
    timezone(E, L6, L7),
    (   B = 24
    ->  A is C*60+D-E
    ;   A is B*3600+C*60+D-E
    ).

time(A, B, C, D, L1, L7) :-
    int(A, L1, [0':|L3]),
    int(B, L3, [0':|L5]),
    decimal(C, L5, L6),
    timezone(D, L6, L7).

duration(A, L1, L7) :-
    dsign(B, L1, [0'P|L3]),
    years(C, L3, L4),
    months(D, L4, L5),
    days(E, L5, L6),
    dtime(F, L6, L7),
    A is B*(C*31556952+D*2629746+E*86400.0+F).

yearmonthduration(A, L1, L5) :-
    dsign(B, L1, [0'P|L3]),
    years(C, L3, L4),
    months(D, L4, L5),
    A is B*(C*12+D).

daytimeduration(A, L1, L5) :-
    dsign(B, L1, [0'P|L3]),
    days(C, L3, L4),
    dtime(D, L4, L5),
    A is B*(C*86400.0+D).

timezone(A, L1, L4) :-
    int(B, L1, [0':|L3]),
    !,
    int(C, L3, L4),
    A is B*3600+C*60.
timezone(0, [0'Z|L2], L2) :-
    !.
timezone(0, L1, L1).

dsign(1, [0'+|L2], L2).
dsign(-1, [0'-|L2], L2).
dsign(1, L1, L1).

dtime(A, [0'T|L2], L5) :-
    !,
    hours(B, L2, L3),
    minutes(C, L3, L4),
    seconds(D, L4, L5),
    A is B*3600+C*60+D.
dtime(0, L1, L1).

years(A, L1, L3) :-
    int(A, L1, [0'Y|L3]).
years(0, L1, L1).

months(A, L1, L3) :-
    int(A, L1, [0'M|L3]).
months(0, L1, L1) .

days(A, L1, L3) :-
    int(A, L1, [0'D|L3]).
days(0, L1, L1).

hours(A, L1, L3) :-
    int(A, L1, [0'H|L3]).
hours(0, L1, L1).

minutes(A, L1, L3) :-
    int(A, L1, [0'M|L3]).
minutes(0, L1, L1).

seconds(A, L1, L3) :-
    decimal(A, L1, [0'S|L3]).
seconds(0, L1, L1).

int(A, L1, L4) :-
    sgn(B, L1, L2),
    digit(C, L2, L3),
    digits(D, L3, L4),
    number_codes(A, [B, C|D]).

decimal(A, L1, L5) :-
    sgn(B, L1, L2),
    digit(C, L2, L3),
    digits(D, L3, L4),
    fraction(E, L4, L5),
    append([B, C|D], E, F),
    number_codes(A, F).

sgn(0'+, [0'+|L2], L2).
sgn(0'-, [0'-|L2], L2).
sgn(0'+, L1, L1).

fraction([0'., A|B], [0'.|L2], L4) :-
    !,
    digit(A, L2, L3),
    digits(B, L3, L4).
fraction([], L1, L1).

digits([A|B], L1, L3) :-
    digit(A, L1, L2),
    digits(B, L2, L3).
digits([], L1, L1).

digit(A, [A|L2], L2) :-
    code_type(A, digit).

fmsec(A, B, C) :-
    integer(A),
    !,
    C is floor(B).
fmsec(_, B, B).

datetime(A, B) :-
    stamp_date_time(A, date(Year, Month, Day, Hour, Minute, Second, _, _, _), 0),
    fmsec(A, Second, Sec),
    ycodes(Year, C),
    ncodes(Month, D),
    ncodes(Day, E),
    ncodes(Hour, F),
    ncodes(Minute, G),
    ncodes(Sec, H),
    append([C, [0'-], D, [0'-], E, [0'T], F, [0':], G, [0':], H, [0'Z]], B).

datetime(Year, Month, Day, Hour, Minute, Second, Offset, B) :-
    ycodes(Year, C),
    ncodes(Month, D),
    ncodes(Day, E),
    ncodes(Hour, F),
    ncodes(Minute, G),
    ncodes(Second, H),
    (   Offset =:= 0
    ->  append([C, [0'-], D, [0'-], E, [0'T], F, [0':], G, [0':], H, [0'Z]], B)
    ;   (   Offset > 0
        ->  I = [0'-],
            OHour is Offset//3600
        ;   I = [0'+],
            OHour is -Offset//3600
        ),
        ncodes(OHour, J),
        OMinute is (Offset mod 3600)//60,
        ncodes(OMinute, K),
        append([C, [0'-], D, [0'-], E, [0'T], F, [0':], G, [0':], H, I, J, [0':], K], B)
    ).

date(A, B) :-
    N is A+3600*12,
    stamp_date_time(N, date(Year, Month, Day, _, _, _, _, _, _), 0),
    ycodes(Year, C),
    ncodes(Month, D),
    ncodes(Day, E),
    Offset is (round(floor(N)) mod 86400) - 3600*12,
    (   Offset =:= 0
    ->  append([C, [0'-], D, [0'-], E, [0'Z]], B)
    ;   (   Offset > 0
        ->  I = [0'-],
            OHour is Offset//3600
        ;   I = [0'+],
            OHour is -Offset//3600
        ),
        ncodes(OHour, J),
        OMinute is (Offset mod 3600)//60,
        ncodes(OMinute, K),
        append([C, [0'-], D, [0'-], E, I, J, [0':], K], B)
    ).

date(Year, Month, Day, Offset, B) :-
    ycodes(Year, C),
    ncodes(Month, D),
    ncodes(Day, E),
    (   Offset =:= 0
    ->  append([C, [0'-], D, [0'-], E, [0'Z]], B)
    ;   (   Offset > 0
        ->  I = [0'-],
            OHour is Offset//3600
        ;   I = [0'+],
            OHour is -Offset//3600
        ),
        ncodes(OHour, J),
        OMinute is (Offset mod 3600)//60,
        ncodes(OMinute, K),
        append([C, [0'-], D, [0'-], E, I, J, [0':], K], B)
    ).

time(A, B) :-
    stamp_date_time(A, date(_, _, _, Hour, Minute, Second, _, _, _), 0),
    fmsec(A, Second, Sec),
    ncodes(Hour, F),
    ncodes(Minute, G),
    ncodes(Sec, H),
    append([F, [0':], G, [0':], H, [0'Z]], B).

time(Hour, Minute, Second, Offset, B) :-
    ncodes(Hour, F),
    ncodes(Minute, G),
    ncodes(Second, H),
    (   Offset =:= 0
    ->  append([F, [0':], G, [0':], H, [0'Z]], B)
    ;   (   Offset > 0
        ->  I = [0'-],
            OHour is Offset//3600
        ;   I = [0'+],
            OHour is -Offset//3600
        ),
        ncodes(OHour, J),
        OMinute is (Offset mod 3600)//60,
        ncodes(OMinute, K),
        append([F, [0':], G, [0':], H, I, J, [0':], K], B)
    ).

yearmonthduration(A, B) :-
    (   A < 0
    ->  C = [0'-]
    ;   C = []
    ),
    D is abs(A),
    E is D//12,
    number_codes(E, Years),
    F is D-(D//12)*12,
    number_codes(F, Months),
    append([C, [0'P], Years, [0'Y], Months, [0'M]], B).

daytimeduration(A, B) :-
    AInt is round(floor(A)),
    AFrac is A-AInt,
    (   AInt < 0
    ->  C = [0'-]
    ;   C = []
    ),
    D is abs(AInt),
    E is D//86400,
    number_codes(E, Days),
    F is (D-(D//86400)*86400)//3600,
    number_codes(F, Hours),
    G is (D-(D//3600)*3600)//60,
    number_codes(G, Minutes),
    H is D-(D//60)*60+AFrac,
    number_codes(H, Seconds),
    append([C, [0'P| Days], [0'D, 0'T| Hours], [0'H| Minutes], [0'M| Seconds], [0'S]], B).

ncodes(A, B) :-
    number_codes(A, D),
    (   A < 10
    ->  B = [0'0| D]
    ;   B = D
    ).

ycodes(A, B) :-
    C is abs(A),
    number_codes(C, D),
    (   C < 10
    ->  E = [0'0, 0'0, 0'0| D]
    ;   (   C < 100
        ->  E = [0'0, 0'0| D]
        ;   (   C < 1000
            ->  E = [0'0| D]
            ;   E = D
            )
        )
    ),
    (   A >= 0
    ->  B = E
    ;   B = [0'-|E]
    ).

absolute_uri('-', '-') :-
    !.
absolute_uri(A, B) :-
    (   is_absolute_url(A)
    ->  B = A
    ;   absolute_file_name(A, C),
        prolog_to_os_filename(D, C),
        atom_codes(D, E),
        subst([[[0x20], [0'%, 0'2, 0'0]]], E, F),
        atom_codes(G, F),
        atomic_list_concat(['file://', G], B)
    ).

resolve_uri(A, _, A) :-
    sub_atom(A, _, 1, _, ':'),
    !.
resolve_uri('', A, A) :-
    !.
resolve_uri('#', A, B) :-
    !,
    atomic_list_concat([A, '#'], B).
resolve_uri(A, B, A) :-
    \+sub_atom(B, _, 1, _, ':'),
    !.
resolve_uri(A, B, C) :-
    so_uri(U),
    atom_length(U, V),
    sub_atom(A, 0, 1, _, '#'),
    sub_atom(B, 0, V, _, U),
    !,
    atomic_list_concat([B, A], C).
resolve_uri(A, B, C) :-
    sub_atom(A, 0, 2, _, './'),
    !,
    sub_atom(A, 2, _, 0, R),
    resolve_uri(R, B, C).
resolve_uri(A, B, C) :-
    sub_atom(A, 0, 3, _, '../'),
    !,
    sub_atom(A, 3, _, 0, R),
    so_uri(U),
    atom_length(U, V),
    sub_atom(B, 0, V, D, U),
    sub_atom(B, V, D, _, E),
    (   sub_atom(E, F, 1, G, '/'),
        sub_atom(E, _, G, 0, H),
        \+sub_atom(H, _, _, _, '/'),
        K is V+F
    ->  sub_atom(B, 0, K, _, S)
    ;   S = B
    ),
    resolve_uri(R, S, C).
resolve_uri(A, B, C) :-
    so_uri(U),
    atom_length(U, V),
    sub_atom(A, 0, 1, _, '/'),
    sub_atom(B, 0, V, D, U),
    sub_atom(B, V, D, _, E),
    (   sub_atom(E, F, 1, _, '/')
    ->  sub_atom(E, 0, F, _, G)
    ;   G = E
    ),
    !,
    atomic_list_concat([U, G, A], C).
resolve_uri(A, B, C) :-
    so_uri(U),
    atom_length(U, V),
    sub_atom(B, 0, V, D, U),
    sub_atom(B, V, D, _, E),
    (   sub_atom(E, F, 1, G, '/'),
        sub_atom(E, _, G, 0, H),
        \+sub_atom(H, _, _, _, '/')
    ->  sub_atom(E, 0, F, _, I)
    ;   I = E
    ),
    !,
    atomic_list_concat([U, I, '/', A], C).
resolve_uri(A, _, _) :-
    nb_getval(line_number, Ln),
    throw(unresolvable_relative_uri(A, after_line(Ln))).

so_uri('http://').
so_uri('https://').
so_uri('ftp://').
so_uri('file://').

wcacher(A, B) :-
    wcache(A, B),
    !.
wcacher(A, B) :-
    wcache(C, D),
    sub_atom(A, 0, I, _, C),
    sub_atom(A, I, _, 0, E),
    atomic_list_concat([D, E], B).

prolog_verb(S, Name) :-
    (   atom(S),
        atom_concat('\'<http://eulersharp.sourceforge.net/2003/03swap/prolog#', A, S),
        atom_concat(B, '>\'', A)
    ->  (   B = conjunction
        ->  Pred = '\', \''
        ;   (   B = disjunction
            ->  Pred = '\';\''
            ;   (   prolog_sym(B, Pred, _)
                ->  true
                ;   nb_getval(line_number, Ln),
                    throw(invalid_prolog_builtin(B, after_line(Ln)))
                )
            )
        ),
        Name = prolog:Pred
    ;   Name = S
    ).

timestamp(Stamp) :-
    get_time(StampN),
    datetime(StampN, StampC),
    atom_codes(StampA, StampC),
    (   sub_atom(StampA, I, 1, 0, 'Z'),
        I > 23
    ->  sub_atom(StampA, 0, 23, _, StampB),
        atomic_list_concat([StampB, 'Z'], Stamp)
    ;   Stamp = StampA
    ).

uuid(UUID) :-
    Version = 4,
    A is random(0xffffffff),
    B is random(0xffff),
    C is random(0x0fff) \/ Version<<12,
    D is random(0x3fff) \/ 0x8000,
    E is random(0xffffffffffff),
    format(atom(UUID),
           '~`0t~16r~8+-~|\c
            ~`0t~16r~4+-~|\c
            ~`0t~16r~4+-~|\c
            ~`0t~16r~4+-~|\c
            ~`0t~16r~12+', [A, B, C, D, E]).

regex(Pattern, String, List) :-
    atom_codes(Pattern, PatternC),
    escape_string(PatC, PatternC),
    atom_codes(Pat, PatC),
    atom_codes(String, StringC),
    escape_string(StrC, StringC),
    atom_codes(Str, StrC),
    re_matchsub(Pat, Str, Dict, []),
    findall(Value,
        (   get_dict(Key, Dict, Value),
            Key \== 0
        ),
        List
    ).

regexp_wildcard([], []) :-
    !.
regexp_wildcard([0'*|A], [0'., 0'*|B]) :-
    !,
    regexp_wildcard(A, B).
regexp_wildcard([A|B], [A|C]) :-
    regexp_wildcard(B, C).

fm(A) :-
    (   A = !
    ->  true
    ;   format(user_error, '*** ~q~n', [A]),
        flush_output(user_error)
    ),
    cnt(fm).

mf(A) :-
    forall(
        catch(A, _, fail),
        (   portray_clause(user_error, A),
            cnt(mf)
        )
    ),
    flush_output(user_error).

