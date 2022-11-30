clc, clear, close all

%-----------------------------{Info}---------------------------------------

% Simulation of the Forge of Empires Winter Event 2022 Minigame

% Known errors:
% 1. Doesn't account for first calendar key find of the day
% 2. Doesn't account for changes in strategy. It will always prioritize the
%    daily special over everything else.
% 3. Probably some errors here and there, let's be honest.

% Programmed by UBERnerd14 (aka UBERhelp1)
% youtube.com/@UBERnerd14
% resite.link/UBERnerd14
% November 29, 2022

%-----------------------{Main Program}-------------------------------------

fullboard = [10, 10, 14, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
             "Shuffle", "Key", "Extra Stars", "Show 2", "2x", "Daily Special", "Prize", "Prize", "Prize", "Prize", "Prize", "Prize", "Prize", "Prize", "Prize", "Prize", "Prize", "Prize"
             0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

% how fullboard is arranged:
            % stars each present gives if won
            % name of present (really should be first row, but ¯\_(ツ)_/¯
            % whether the present is visible or not (1 if shown, 0 if not)

trials = 100; % number of simulated boards the program will run
t = 1; % don't change, number of trials completed

% initializes tracker variables
totalStars = 0;
totalDS = 0;
totalMatches = 0;

% main loop
while t <= trials

    % variable re-initialization for each board

    plist = fullboard; %resets list of presents
    shuffle = 0; % whether the shuffle has been picked
    stars = 0; % number of stars spent per board
    matches = 0; % number of matches found (also number of presents)
    presents = strings(3, 18); % used to track which presents were won
    reveal = 0; % whether the show 2 has been found
    special = 0; % whether the daily special has been found
    choices = []; % list of our choices for show 2, if it is found
    values = []; % list of values for show 2
    p = 0; % number of presents opened
    ds = 0; % number of daily specials found

    % this loop is for each board

    while (size(plist, 2) > 0) && (shuffle ~= 1)
        
        % find the number of present we are on
        numprez = 19 - size(plist, 2);

        p = p + 1; % increment number of presents openend

        % if selecting from show 2 choose those, otherwise pick random
        if choices 
            if plist(2, choices(1)) ~= "Shuffle" || plist(2, choices(1)) == "Shuffle" && special == 1
                pick = choices(1);
                choices(1) = [];
            end
        else
            pick = fix(size(plist, 2) * rand) + 1;
        end

        % add the current present pick to the list of opened presents
        % used for debugging
        presents(:, p) = plist(:, pick);

        % special present cases code
        if plist(2, pick) == "Shuffle"
            shuffle = 1;
        end
        if p > 1 && presents(2, p - 1) == "2x"
            % this line is duplicated onto line 97, basically adding the
            % stars twice. It was easier than a more complicated solution
            stars = stars - str2double(plist(1, pick));
        end
        if plist(2, pick) == "Daily Special"
            special = 1;
            if p > 1 && presents(2, p - 1) == "2x"
                ds = ds + 1;
            end
            ds = ds + 1;
        end

        % uncomment line below to print an order of each present found (kinda spammy)
        %fprintf("Present %i: %s\n", p, plist(2, pick))

        % update number of stars spent
        stars = stars + 10 - str2double(plist(1, pick));

        % remove the current pick from the list of available choices
        plist(:, pick) = [];

        % the trickiest part. Figuring out what to do when finding "Show 2"
        if presents(2, numprez) == "Show 2"

            if numprez < 16 % if there's more than 2 presents left

                % pick 2 random presents from what's left

                values = randperm(17 - numprez);
                values = sort(values(1:2), 'descend');
                plist(3, values) = 1; % mark these prizes as revealed (debugging)

                % uncomment line below to show which presents were revealed
                %fprintf("Revealed: %s and %s\n", plist(2, values(1)), plist(2, values(2)))

                % set choices to the order of prizes we want, remove those we don't
                i = 1;

                % runs twice, for each present
                while i <= 2

                    % for the 2x present
                    if plist(2, values(i)) == "2x"
                        % You want to always pick the 2x first
                        if choices
                            choices(2) = choices(1);
                        end
                        choices(1) = values(i);

                    % for the DS, Stars, and Key presents
                    elseif plist(2, values(i)) == "Daily Special" || plist(2, values(i)) == "Extra Stars" || plist(2, values(i)) == "Key"
                        % checks if the first choice is taken already
                        if isempty(choices) || plist(2, choices(1)) ~= "2x"
                            % checks if shuffle has been added yet
                            if ~isempty(choices) && plist(2, choices(1)) == "Shuffle"
                                % puts itself in front of the shuffle
                                choices(2) = choices(1);
                                choices(1) = values(i);
                            else
                            choices(1) = values(i);
                            end
                        else
                            choices(2) = values(i);
                        end
                    
                    % for the shuffle present    
                    elseif plist(2, values(i)) == "Shuffle"
                        if isempty(choices)
                            choices(1) = values(i);
                        else
                            choices(2) = values(i);
                        end
                    % this is for general prizes if uncovered
                    else
                        plist(:, values(i)) = [];
                    end

                    i = i + 1;
                end
            end
            reveal = 1;
        end
        matches = matches + 1;
    end
    % uncomment line below to show totals for each board
    %fprintf("- %i presents, %i stars spent, %i DS\n", p, stars, ds)

    % variable calculation for final totals/final averages
    totalMatches = totalMatches + matches;
    totalDS = totalDS + ds;
    totalStars = totalStars + stars;
    t = t + 1;
end

% print final totals/averages

fprintf("Totals: \n - Presents Opened: %i\n - Daily Specials: %i\n - Stars Spent: %i\n - Grand Prizes: %i\n\n", totalMatches, totalDS, totalStars, fix((1.8 * totalMatches) / 20))

starsDS = round(totalStars / totalDS, 2);
prezDS = round(totalMatches / totalDS, 2);
starsGP = round(totalStars / ((1.8 * totalMatches) / 20), 2);

fprintf("Averages:\n - Stars per DS: %.2f\n - Presents per DS: %.2f\n - Stars per Grand Prize: %.2f\n\n", starsDS, prezDS, starsGP);
