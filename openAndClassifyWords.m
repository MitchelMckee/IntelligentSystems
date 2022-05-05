fidPositive = fopen(fullfile('positive-words.txt'));
fidNegative = fopen(fullfile('negative-words.txt'));
C = textscan(fidPositive,'%s','CommentStyle',';');
B = textscan(fidNegative,'%s','CommentStyle',';');
wordsPositive = string(C{1});
wordsNegative = string(B{1});
fclose all;

words_hash = java.util.Hashtable;
[possize, ~] = size(wordsPositive);
[negsize,~] = size(wordsNegative);
for ii = 1:possize
    words_hash.put(wordsPositive(ii,1),1);
end
for ii = 1:negsize
    words_hash.put(wordsNegative(ii,1),-1);
end
