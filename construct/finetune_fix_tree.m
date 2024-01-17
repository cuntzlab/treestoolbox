function [OutAPReptree, OutTrueInd] = finetune_fix_tree(FixTree, APReptree, bf, TrueInd, polyshape, mNBr, mDlen)

%% prune node by node until reaching NrBr (start with shortest branch)
% dont prune of incomplete ends if existent
%     APReptree = elimt_tree(APReptree);
%     mNBr = sum(B_tree(handles.referencetree))
%     mDlen = sum(len_tree(handles.referencetree))
CurrNrBr = sum(B_tree(APReptree));
CurrDLen = sum(len_tree(APReptree));
if CurrNrBr < mNBr
    disp('Pruning to your specified length is not possible since Repaired Dendritic length is insuficient');
    disp('Please increase the number of carrier Points for 1 or more Volume/s');
end
lenAPtree = len_tree(APReptree);
NewNodesInd = TrueInd;
[prsect, prvec] = dissect_tree(APReptree);
allnewSegs = unique(prvec(NewNodesInd, 1));

if isempty(FixTree)
    FixTree = delete_tree(APReptree, 3:1:length(APReptree.R));
end

newInComI = [];
if isfield(FixTree, 'IncompleteTerminals')
    FixTree.IncompleteTerminals = APReptree.IncompleteTerminals;
    FixTree.FormerIncTerms = APReptree.FormerIncTerms;
    Unc = 3;
    for ggt = 1:length(FixTree.IncompleteTerminals(:, 1))
        tempINCOMP = find(APReptree.X >= FixTree.IncompleteTerminals(ggt, 1)-Unc & ...
            APReptree.X <= FixTree.IncompleteTerminals(ggt, 1)+Unc & ...
            APReptree.Y >= FixTree.IncompleteTerminals(ggt, 2)-Unc & ...
            APReptree.Y <= FixTree.IncompleteTerminals(ggt, 2)+Unc & ...
            APReptree.Z >= FixTree.IncompleteTerminals(ggt, 3)-Unc & ...
            APReptree.Z <= FixTree.IncompleteTerminals(ggt, 3)+Unc);
        newInComI = [newInComI; tempINCOMP];
    end
    availSects = unique(prvec(newInComI, 1));
    select1 = [];
    for ggt = 1:length(availSects)
        tempsel = find(prvec(newInComI, 1) == availSects(ggt));
        select1 = [select1, tempsel(1)];
    end
    newInComI = newInComI(select1);
end

% get rid of all nodes that are part of incomplete sections from
% original neuron
delFromNewSegs = [];
delFromNewNodes = [];
for PrCtr = 1:length(allnewSegs)
    if ismember(allnewSegs(PrCtr), prvec(newInComI, 1))
        delFromNewSegs = [delFromNewSegs, PrCtr];
        delFromNewNodes = [delFromNewNodes; find(prvec(NewNodesInd, 1) == allnewSegs(PrCtr))];
    else
    end
end
delSegs = allnewSegs(delFromNewSegs);
allnewSegs(delFromNewSegs) = [];
NewNodesInd(delFromNewNodes) = [];


% get rid of all segments that are not terminal
getTermSegs = ismember(allnewSegs, unique(prvec(T_tree(APReptree), 1)));
allnewSegs = allnewSegs(getTermSegs);
% get secondary terminal branches in case pruning all terminals is not
% sufficient
SeconTermSegs = unique(prvec(prsect(allnewSegs, 1), 1));
SeconTermSegs(ismember(SeconTermSegs, delSegs)) = [];

SegLen = [];
for PrCtr = 1:length(allnewSegs)
    checkNewSegI = prvec(NewNodesInd, 1) == allnewSegs(PrCtr);
    SegLen(PrCtr) = sum(lenAPtree(NewNodesInd(checkNewSegI)));
end

Seg2Len = [];
for PrCtr = 1:length(SeconTermSegs)
    checkNewSegI = prvec(NewNodesInd, 1) == SeconTermSegs(PrCtr);
    Seg2Len(PrCtr) = sum(lenAPtree(NewNodesInd(checkNewSegI)));
end

% prune away segments until number of branches is reached starting with
% the shortest
EditTree = APReptree;
if isempty(mNBr)
else
    DelFromTree = [];
    while CurrNrBr > mNBr
        EditTree = APReptree;
        [~, SegI] = min(SegLen);
        DelAdd = prvec(NewNodesInd, 1) == allnewSegs(SegI);
        DelFromTree = [DelFromTree; NewNodesInd(DelAdd)];
        EditTree = delete_tree(EditTree, DelFromTree);
        CurrNrBr = sum(B_tree(EditTree));
        SegLen(SegI) = [];
        allnewSegs(SegI) = [];
        if isempty(allnewSegs)
            break;
        end
    end

    % if pruning terminal branches was not sufficient this part prunes
    % secondary branches as well
    if CurrNrBr > mNBr
        while CurrNrBr > mNBr
            EditTree = APReptree;
            if isempty(Seg2Len)
                disp('no secondary branches to prune');
                break;
            end
            [~, SegI] = min(Seg2Len);
            DelAdd = prvec(NewNodesInd, 1) == SeconTermSegs(SegI);
            Seg2Len(SegI) = [];
            SeconTermSegs(SegI) = [];
            DelFromTree = [DelFromTree; NewNodesInd(DelAdd)];
            EditTree = delete_tree(EditTree, DelFromTree);
            %             figure; hold on;
            %             plot_tree(APReptree,[1 0 0]);
            %             plot_tree(EditTree); shine;
            CurrNrBr = sum(B_tree(EditTree));
            if isempty(SeconTermSegs)
                break;
            end
        end
    end

    if CurrNrBr > mNBr
        disp('desired number of branches could not be reached via automatic pruning!')
    end
    if isfield(APReptree, 'AddedMain')
        delSegLen = [];
        for PrCtr = 1:length(delSegs)
            checkNewSegI = prvec(TrueInd, 1) == delSegs(PrCtr);
            delSegLen(PrCtr) = sum(lenAPtree(TrueInd(checkNewSegI)));
        end
        while CurrNrBr > mNBr
            EditTree = APReptree;
            [~, SegI] = min(delSegLen);
            DelAdd = prvec(TrueInd, 1) == delSegs(SegI);
            delSegLen(SegI) = [];
            delSegs(SegI) = [];
            DelFromTree = [DelFromTree; TrueInd(DelAdd)];
            EditTree = delete_tree(EditTree, DelFromTree);
            %             figure; hold on;
            %             plot_tree(APReptree,[1 0 0]);
            %             plot_tree(EditTree); shine;
            CurrNrBr = sum(B_tree(EditTree));
            if isempty(delSegs)
                break;
            end
        end
    end
end

%% if dend length still too high prune random termination nodes until Dlen equal or smaller
% agian dont prune of incpmplete branches if existent
% dont prune entire branch last node of branch has to stay
if isempty(mDlen)
else
    CurrDLen = sum(len_tree(EditTree));
    if CurrDLen > mDlen

        TrueInd = find(EditTree.D == 1);

        NewNodesInd = TrueInd;
        [prsect, prvec] = dissect_tree(EditTree);
        allnewSegs = unique(prvec(NewNodesInd, 1));
        lenAPtree = len_tree(EditTree);

        newInComI = [];
        if isfield(FixTree, 'IncompleteTerminals')
            Unc = 3;
            for ggt = 1:length(FixTree.FormerIncTerms(:, 1))
                tempINCOMP = find(EditTree.X >= FixTree.FormerIncTerms(ggt, 1)-Unc & ...
                    EditTree.X <= FixTree.FormerIncTerms(ggt, 1)+Unc & ...
                    EditTree.Y >= FixTree.FormerIncTerms(ggt, 2)-Unc & ...
                    EditTree.Y <= FixTree.FormerIncTerms(ggt, 2)+Unc & ...
                    EditTree.Z >= FixTree.FormerIncTerms(ggt, 3)-Unc & ...
                    EditTree.Z <= FixTree.FormerIncTerms(ggt, 3)+Unc);
                newInComI = [newInComI; tempINCOMP];
            end
            availSects = unique(prvec(newInComI, 1));
            select1 = [];
            for ggt = 1:length(availSects)
                tempsel = find(prvec(newInComI, 1) == availSects(ggt));
                select1 = [select1, tempsel(1)];
            end
            newInComI = newInComI(select1);
        end

        % get rid of all nodes that are part of incomplete sections from
        % original neuron
        delFromNewSegs = [];
        delFromNewNodes = [];
        for PrCtr = 1:length(allnewSegs)
            if ismember(allnewSegs(PrCtr), prvec(newInComI, 1))
                delFromNewSegs = [delFromNewSegs, PrCtr];
                delFromNewNodes = [delFromNewNodes; find(prvec(NewNodesInd, 1) == allnewSegs(PrCtr))];
            else
            end
        end
        allnewSegs(delFromNewSegs) = [];
        NewNodesInd(delFromNewNodes) = [];

        DelFromTree = [];
        CurrTermPts = T_tree(EditTree);
        CurrTermPts = NewNodesInd(CurrTermPts(NewNodesInd) == 1);
        %         DirParN = idpar_tree(EditTree);
        breakctr = 0;
        if ~isempty(CurrTermPts)
            while CurrDLen > mDlen
                Edit2Tree = EditTree;
                ChosN = CurrTermPts(randi([1, length(CurrTermPts)]));
                segNCarPts = find(prvec(:, 1) == prvec(ChosN, 1));
                SegLeng = sum(lenAPtree(segNCarPts));
                if length(segNCarPts) > 4
                    DelFromTree = [DelFromTree; segNCarPts(floor(length(segNCarPts)*0.2):end)];
                    Edit2Tree = delete_tree(Edit2Tree, DelFromTree);
                end
                CurrDLen = sum(len_tree(Edit2Tree));
                CurrTermPts(CurrTermPts == ChosN) = [];
                if isempty(CurrTermPts)
                    break;
                end

                % %             ChosP = DirParN(ChosN);
                % %             ecessL = CurrDLen-mDlen;
                % %             PtoTv(1) = Edit2Tree.X(ChosN)-Edit2Tree.X(ChosP);
                % %             PtoTv(2) = Edit2Tree.Y(ChosN)-Edit2Tree.Y(ChosP);
                % %             PtoTv(3) = Edit2Tree.Z(ChosN)-Edit2Tree.Z(ChosP);
                % %             LenPtoTv = norm(PtoTv)
                % %             if LenPtoTv < ecessL
                % %                 PtoTv = PtoTv*0.2;
                % %             elseif LenPtoTv >= ecessL
                % %                 disp('hi')
                % %                 PtoTv = PtoTv*(ecessL/LenPtoTv);
                % %             end
                % %             Edit2Tree.X(ChosN) = Edit2Tree.X(ChosP)+PtoTv(1);
                % %             Edit2Tree.Y(ChosN) = Edit2Tree.Y(ChosP)+PtoTv(2);
                % %             Edit2Tree.Z(ChosN) = Edit2Tree.Z(ChosP)+PtoTv(3);
                CurrDLenPrev = CurrDLen;
                CurrDLen = sum(len_tree(Edit2Tree));
                if CurrDLenPrev == CurrDLen
                    breakctr = breakctr + 1;
                end
                if breakctr == 100
                    break;
                end
            end
            EditTree = Edit2Tree;
        end
    end

    %% after procedure dendlength will likely be too low
    % elongate branches at termination points
    % dont go beyond volume constraints

    CurrDLen = sum(len_tree(EditTree));
    if CurrDLen < mDlen

        TrueInd = find(EditTree.D == 1);

        NewNodesInd = TrueInd;
        [prsect, prvec] = dissect_tree(EditTree);
        allnewSegs = unique(prvec(NewNodesInd, 1));
        lenAPtree = len_tree(EditTree);

        % find terminals of new part of tree
        CurrTermPts = find(T_tree(EditTree) == 1);
        CurrNewTermPts = ismember(NewNodesInd, CurrTermPts) == 1;
        CurrNewTermPts = NewNodesInd(CurrNewTermPts);

        % cut missing length into portions to be added to the tree
        missLen = mDlen - CurrDLen;
        addmod = 0.3;
        addLenPerIt = missLen / ceil(addmod*missLen);
        oldinds = length(EditTree.R);

        for addctr = 1:ceil(addmod*missLen)
            bearkctr = 0;
            TermIndrand = randperm(length(CurrNewTermPts));
            while bearkctr < length(CurrNewTermPts)
                bearkctr = bearkctr + 1;
                ChosT = CurrNewTermPts(TermIndrand(bearkctr)); %randi([1 length(CurrNewTermPts)]));
                parNodes = idpar_tree(EditTree);
                ParN = parNodes(ChosT);
                conVec(1) = EditTree.X(ChosT) - EditTree.X(ParN);
                conVec(2) = EditTree.Y(ChosT) - EditTree.Y(ParN);
                conVec(3) = EditTree.Z(ChosT) - EditTree.Z(ParN);
                conVec = conVec / norm(conVec);
                [azimuth, elevation, ~] = cart2sph(conVec(1), conVec(2), conVec(3));
                aziscattratio = -0.35 * bf + 0.4;
                elescattratio = aziscattratio / 2;
                aziscatt = azimuth + rand(1000, 1) * pi * aziscattratio;
                aziscatt = [aziscatt; azimuth - rand(1000, 1) * pi * aziscattratio];
                aziscatt = [aziscatt; azimuth - rand(1000, 1) * pi * aziscattratio];
                aziscatt = [aziscatt; azimuth + rand(1000, 1) * pi * aziscattratio];
                elescatt = elevation + rand(1000, 1) * pi * elescattratio;
                elescatt = [elescatt; elevation - rand(1000, 1) * pi * elescattratio];
                elescatt = [elescatt; elevation + rand(1000, 1) * pi * elescattratio];
                elescatt = [elescatt; elevation - rand(1000, 1) * pi * elescattratio];
                [x, y, z] = sph2cart(aziscatt, elescatt, addLenPerIt);
                chooseind = randi([1, length(x)]);
                conVec(1) = x(chooseind);
                conVec(2) = y(chooseind);
                conVec(3) = z(chooseind);
                % check whether point is outside of volume
                if ~isempty(polyshape)
                    for polyctr = 1:length(polyshape)
                        Ptcheck(1) = EditTree.X(ChosT) + conVec(1);
                        Ptcheck(2) = EditTree.Y(ChosT) + conVec(2);
                        Ptcheck(3) = EditTree.Z(ChosT) + conVec(3);
                        if sum(polyshape{polyctr}.vertices(:, 3)) == 0
                            Ptchyes = inpolygon(Ptcheck(1), Ptcheck(2), polyshape{polyctr}.vertices(:, 1), polyshape{polyctr}.vertices(:, 2));
                        else
                            Ptchyes = inpolyhedron(polyshape{polyctr}, Ptcheck);
                        end
                        if Ptchyes == 1
                            break;
                        end
                    end
                else
                    Ptchyes = 1;
                end
                if Ptchyes == 1
                    bearkctr = length(CurrNewTermPts);
                end
            end

            %             conVec = conVec*addLenPerIt;

            EditTree.dA = [EditTree.dA, zeros(length(EditTree.R), 1)];
            EditTree.dA = [EditTree.dA; zeros(1, length(EditTree.R)+1)];
            EditTree.X(end+1) = EditTree.X(ChosT) + conVec(1);
            EditTree.Y(end+1) = EditTree.Y(ChosT) + conVec(2);
            EditTree.Z(end+1) = EditTree.Z(ChosT) + conVec(3);
            EditTree.D(end+1) = EditTree.D(ChosT);
            EditTree.R(end+1) = EditTree.R(ChosT);
            EditTree.dA(length(EditTree.R), ChosT) = 1;

            CurrNewTermPts(end+1) = length(EditTree.R);
            CurrNewTermPts(CurrNewTermPts == ChosT) = [];
        end

        % delete points outside the volume
        insider = [];
        if ~isempty(polyshape)
            for polyctr = 1:length(polyshape)
                NewPts(:, 1) = EditTree.X(oldinds+1:end);
                NewPts(:, 2) = EditTree.Y(oldinds+1:end);
                NewPts(:, 3) = EditTree.Z(oldinds+1:end);
                if sum(polyshape{polyctr}.vertices(:, 3)) == 0
                    yes = inpolygon(NewPts(:, 1), NewPts(:, 2), polyshape{polyctr}.vertices(:, 1), polyshape{polyctr}.vertices(:, 2));
                else
                    yes = inpolyhedron(polyshape{polyctr}, NewPts);
                end
                insider = [insider; find(yes == 1)];
            end
            AllindsCheck = 1:1:size(NewPts, 1);
            insider = unique(insider);
            outsider = find(~ismember(AllindsCheck, insider) == 1);
            outsider = outsider + oldinds;
            EditTree = delete_tree(EditTree, outsider);
        end
    end
end

OutAPReptree = EditTree;

OutTrueInd = find(OutAPReptree.D == 1);
end

%% after procedure dendlength will likely be too low
% elongate branches at termination points
% dont go beyond volume constraints