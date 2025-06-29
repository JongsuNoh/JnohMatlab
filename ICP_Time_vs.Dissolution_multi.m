%% Convert ICPMS data to Time/Dissolution data
%% Made by Jongsu Noh

fileinfo=dir('*.rep*')
[total,~] = size(fileinfo);

TEs = {'Pt', 'Ir'};  % Target elements // {'Pt', 'Ir'}
[~, NEs] = size(TEs);
Tinterval = 1.004;   % time interval

for i0= 1:total
    filename=fileinfo(i0).name;
    fid = fopen(filename, 'r');

    rows = {};
    while ~feof(fid)
        line = fgetl(fid);
            if startsWith(line, '"') && endsWith(line, '"')
                line = extractBetween(line, 2, strlength(line)-1);
                line = char(line);  % extractBetween 결과는 string이므로 char로 변환
            end
        tokens = regexp(line, '[\t, ]+', 'split'); % 쉼표, 탭, 공백 기준으로 나누기
        tokens = tokens(~cellfun('isempty', tokens)); 
        rows{end+1,1} = tokens;
    end
fclose(fid);

% Normalize to rectangular cell array
maxCols = max(cellfun(@numel, rows));
normalized = cell(length(rows), maxCols);

for i = 1:length(rows)
    r = rows{i};
    normalized(i,1:numel(r)) = r;
end


data = []; % Initialize numeric data matrix

    for r0 = 1:NEs
        index = {};
        
        for r = 2:size(normalized, 1)
            % 필터: 대상 원소이면서, 11열(standard 등)이 비어 있는 경우
            if strcmp(normalized{r,1},TEs{r0})&&(isempty(normalized{r, 10}))
                % 위치 체크!
            index{end+1,1} = normalized{r,6};
            end
        end
        data(:,r0) = str2double(index); %data에 열별로 저장
    end

    % Time 열 생성
    timeCol = (1:length(data))' * Tinterval;
    data = [timeCol, data];
    
    % excel file 생성
    varNames = {"Time", TEs{1:NEs}};
    datacell = [varNames; num2cell(data)];
    dataname = sprintf('ICPMS_%d.xlsx', i0);
    writecell(datacell, dataname);
end

