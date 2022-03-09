% Generating deep taxonomy

:- use_module(library(between)).
:- use_module(library(format)).

run :-
    open('dt.n3p',write,Out),
    write(Out,'% Deep taxonomy\n'),
    write(Out,'% See http://ruleml.org/WellnessRules/files/WellnessRulesN3-2009-11-10.pdf\n'),
    write(Out,'\n'),
    write(Out,'\'http://www.w3.org/1999/02/22-rdf-syntax-ns#type\'(\'example.org/ns#z\',\'example.org/ns#N0\').\n'),
    write(Out,'\n'),
    (   between(0,9999,I),
        J is I+1,
        format(Out,"'http://www.w3.org/1999/02/22-rdf-syntax-ns#type'(X,'example.org/ns#N~d') <= 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type'(X,'example.org/ns#N~d').~n",[J,I]),
        format(Out,"'http://www.w3.org/1999/02/22-rdf-syntax-ns#type'(X,'example.org/ns#I~d') <= 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type'(X,'example.org/ns#N~d').~n",[J,I]),
        format(Out,"'http://www.w3.org/1999/02/22-rdf-syntax-ns#type'(X,'example.org/ns#J~d') <= 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type'(X,'example.org/ns#N~d').~n",[J,I]),
        fail
    ;   true
    ),
    write(Out,'\n'),
    write(Out,'% query\n'),
    write(Out,'\'http://www.w3.org/1999/02/22-rdf-syntax-ns#type\'(_ELEMENT,\'example.org/ns#N1\') => true.\n'),
    write(Out,'\'http://www.w3.org/1999/02/22-rdf-syntax-ns#type\'(_ELEMENT,\'example.org/ns#N10\') => true.\n'),
    write(Out,'\'http://www.w3.org/1999/02/22-rdf-syntax-ns#type\'(_ELEMENT,\'example.org/ns#N100\') => true.\n'),
    write(Out,'\'http://www.w3.org/1999/02/22-rdf-syntax-ns#type\'(_ELEMENT,\'example.org/ns#N1000\') => true.\n'),
    write(Out,'\'http://www.w3.org/1999/02/22-rdf-syntax-ns#type\'(_ELEMENT,\'example.org/ns#N10000\') => true.\n'),
    close(Out).
