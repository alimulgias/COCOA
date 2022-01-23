function probablities=ZipfProbability(numberOfFunctions, zipfShape)

    tmp=zeros(numberOfFunctions,1);
    probablities=zeros(numberOfFunctions,1);

    tmpTot=0;
    for k = 1:numberOfFunctions
        tmp(k) = 1.0 /(k^zipfShape);
        tmpTot = tmpTot+tmp(k);
    end

    for k = 1:numberOfFunctions
        probablities(k) = tmp(k) / tmpTot;
    end
    
end
