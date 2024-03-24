% 1
list_orders(Customer, Orders) :-
    customer(CustomerId, Customer),
    list_orders_helper(CustomerId, [], TempOrders),
    reverse(TempOrders, Orders).

list_orders_helper(CustomerId, AccOrders, Orders) :-
    order(CustomerId, OrderId, Items),
    append(AccOrders, [order(CustomerId, OrderId, Items)], NewAccOrders),
    fail.
list_orders_helper(_, Orders, Orders).

% 2
countOrdersOfCustomer(Customer, Count) :-
    customer(CustomerId, Customer),
    findall(OrderId, order(CustomerId, OrderId, _), Orders),
    length_Me(Orders, Count).

length_Me([],0).
length_Me([_|T],R):- 
    length_Me(T,R1),
    R is 1 + R1.

% 3
getItemsInOrderById(Customer, OrderId, Items) :-
    customer(CustomerId, Customer),
    order(CustomerId, OrderId, Items).

% 4
getNumOfItems(Customer, OrderId, Count) :-
    customer(CustomerId, Customer),
    order(CustomerId, OrderId, Items), 
    length_Me(Items, Count).

% 5
calcPriceOfOrder(Customer, OrderId, TotalPrice) :-
    customer(CustomerId, Customer),
    order(CustomerId, OrderId, Items),
    calculateTotalPrice(Items, TotalPrice).

calculateTotalPrice([], 0).
calculateTotalPrice([Item|Rest], TotalPrice) :-
    item(Item, _, Price),
    calculateTotalPrice(Rest, RemainingPrice),
    TotalPrice is Price + RemainingPrice.

% 6
isBoycott(ItemOrCompanyName) :-
    boycott_company(ItemOrCompanyName, _Reason),!.

isBoycott(ItemOrCompanyName) :-
    alternative(ItemOrCompanyName, _),!.

% 7
whyToBoycott(ItemOrCompanyName, Justification) :-
    (   item(ItemOrCompanyName, CompanyName, _)
    ->  (   boycott_company(CompanyName, Justification)
        ->  true
        ;   Justification = 'No boycott justification found for this item/company.'
        )
    ;   (   boycott_company(ItemOrCompanyName, Justification)
        ->  true
        ;   Justification = 'No boycott justification found for this item/company.'
        )
    ).

% 8
removeBoycottItems([], []) :- !.
removeBoycottItems([Item|Tail], Filtered) :-
    (   isBoycott(Item) 
    ->  removeBoycottItems(Tail, Filtered) 
    ;   Filtered = [Item|Rest],
        removeBoycottItems(Tail, Rest)
    ).

removeBoycottItemsFromOrder(CustomerId, OrderId, NewList) :-
    getItemsInOrderById(CustomerId, OrderId, Items),
    removeBoycottItems(Items, NewList),
    !.

% 9
replaceBoycottItems([], []).
replaceBoycottItems([Item|Tail], [Replacement|Rest]) :-
    (   alternative(Item, Replacement)
    ->  true
    ;   Replacement = Item
    ),
    replaceBoycottItems(Tail, Rest).

replaceBoycottItemsFromAnOrder(CustomerId, OrderId, NewList) :-
    getItemsInOrderById(CustomerId, OrderId, Items),
    replaceBoycottItems(Items, NewList),
    !.

% 10
calcPriceAfterReplacingBoycottItemsFromAnOrder(CustomerId, OrderId, NewList, TotalPrice) :-
    replaceBoycottItemsFromAnOrder(CustomerId, OrderId, NewList),
    calculateTotalPrice(NewList, TotalPrice).

% 11
getTheDifferenceInPriceBetweenItemAndAlternative(ItemName, Alternative, DiffPrice) :-
    alternative(ItemName, Alternative),
    item(ItemName, _, Price1),
    item(Alternative, _, Price2),
    DiffPrice is Price1 - Price2.

% 12 you need to make in the first the :- dynamic item/3.    % need to be change

% Add a new item to the knowledge base
add_item(ItemName, Company, Price) :-
    assert(item(ItemName, Company, Price)). 

% Remove an item from the knowledge base
remove_item(ItemName, _, _) :-
    retract(item(ItemName, _, _)).

% Add a new alternative to the knowledge base
add_alternative(ItemName, Alternative) :-
    assert(alternative(ItemName, Alternative)).

% Remove an alternative from the knowledge base
remove_alternative(ItemName, Alternative) :-
    retract(alternative(ItemName, Alternative)).

% Add a new company to boycott
add_boycott_company(CompanyName, Reason) :-
    assert(boycott_company(CompanyName, Reason)).

% Remove a boycotted company from the knowledge base
remove_boycott_company(CompanyName, _) :-
    retract(boycott_company(CompanyName, _)).
