filename = "apple01-03.txt";
%filename = "apple04-06.txt";
%filename = "apple07-09.txt";
%filename = "apple2.txt";
%filename = "virginTweets.txt"; 
%filename = "americanAirwaysTweets.txt";
%filename  = "unitedTweets";

dataReviews = readtable(filename,'TextType','string');
textData = dataReviews.text; 
actualScore = dataReviews.sentiment;

sents = preprocessReviews(textData);
sentimentScore = zeros(size(sents));

for ii = 1 : sents.length
    docwords = sents(ii).Vocabulary;
    for jj = 1 : length(docwords)
        if words_hash.containsKey(docwords(jj))
            sentimentScore(ii) = sentimentScore(ii) +  words_hash.get(docwords(jj));
        end
    end
end

sentimentScore(sentimentScore > 0) = 1;   
sentimentScore(sentimentScore < 0)= -1;   

notfound = sum(sentimentScore == 0);
covered = numel(sentimentScore) - notfound;

tp = sentimentScore((sentimentScore > 0) & ( actualScore >0));
tn = sentimentScore((sentimentScore  < 0) &( actualScore == 0));
acc = (sum(tp) - sum(tn))/sum(covered);

fprintf("-------- WORD BASED ANALYSIS RESULTS --------\n");
fprintf("Coverage: %2.2f%%, found  %d, missed: %d\n", (covered * 100)/numel(sentimentScore), covered, notfound);
fprintf("Accuracy: %2.2f%%, tp: %d, tn: %d\n", acc*100, sum(tp), -sum(tn));

numWords = size(data, 1);
cvp = cvpartition(numWords, 'HoldOut', 0.01); 
dataTrain = data(training(cvp),:);
dataTest = data(test(cvp),:);

wordsTrain = dataTrain.Word;
XTrain = word2vec(emb, wordsTrain);
YTrain = dataTrain.Label;

model = fitcsvm(XTrain, YTrain);

idx = ~isVocabularyWord(emb, sents.Vocabulary); %18b
removeWords(sents, idx);

sentimentScore = zeros(size(sents));

for ii = 1 : sents.length
    docwords = sents(ii).Vocabulary;
    vec = word2vec(emb, docwords);
    [~,scores] = predict(model, vec);
    sentimentScore(ii) = mean(scores(:, 1));
    if isnan(sentimentScore(ii))
        sentimentScore(ii) = 0;
    end
end

sentimentScore(sentimentScore > 0) = 1;  
sentimentScore(sentimentScore < 0)= -1;  
notfound = sum(sentimentScore == 0);
covered = numel(sentimentScore) - notfound;
tp = sentimentScore((sentimentScore > 0) & ( actualScore >0));
tn = sentimentScore((sentimentScore  < 0) &( actualScore == 0));
acc = (sum(tp) - sum(tn))/sum(covered);

fprintf("-------- SVM RESULTS --------\n")
fprintf("Coverage: %2.2f%%, found  %d, missed: %d\n", (covered * 100)/numel(sentimentScore), covered, notfound);
fprintf("Accuracy: %2.2f%%, tp: %d, tn: %d\n", acc*100, sum(tp), -sum(tn));

sentimentScore = zeros(size(sents));

for ii = 1 : sents.length
    docwords = sents(ii).Vocabulary;
    for jj = 1 : length(docwords)
        if words_hash.containsKey(docwords(jj))
            sentimentScore(ii) = sentimentScore(ii) +  words_hash.get(docwords(jj));
        end
    end
    if sentimentScore(ii) == 0
        vec = word2vec(emb,docwords);
        [~,scores] = predict(model,vec);
        sentimentScore(ii) = mean(scores(:,1));
        if isnan(sentimentScore(ii))
            sentimentScore(ii) = 0;
        end
    end
end

sentimentScore(sentimentScore > 0) = 1;   
sentimentScore(sentimentScore < 0)= -1;
notfound = sum(sentimentScore == 0);
covered = numel(sentimentScore) - notfound;
tp = sentimentScore((sentimentScore > 0) & ( actualScore >0));
tn = sentimentScore((sentimentScore  < 0) &( actualScore == 0));
acc = (sum(tp) - sum(tn))/sum(covered);

fprintf("-------- ENSEMBLE RESULTS --------\n")
fprintf("Coverage: %2.2f%%, found  %d, missed: %d\n", (covered * 100)/numel(sentimentScore), covered, notfound);
fprintf("Accuracy: %2.2f%%, tp: %d, tn: %d\n", acc*100, sum(tp), -sum(tn));
   


    
