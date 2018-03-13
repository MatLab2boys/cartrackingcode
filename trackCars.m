clear all; %closes all values in the workspace 
close all; %closes all figures

%prompts the user to choose the file or cancel 
choice = questdlg('Welcome to Car Tracking, select a video file to track.'...
    , 'Car Tracking Program', 'Select a File', 'Cancel', 'Select a File');
switch choice
    case 'Select a File' %if the user presses this, they will be prompted to select a file 
        [FileName,PathName] = uigetfile('*.mp4','Select the video file');
        
        
        trafficVideo = VideoReader(FileName); %reads the selected video 
        numberFrames = trafficVideo.NumberOfFrames; %finds the number of frames of the video 
        frameRate = trafficVideo.FrameRate; %finds the frame rate of the video 
        x = 0; 
        h = waitbar(x,'Analyzing Video...'); %opens a loading bar 
       
        for i = 1:numberFrames 
            iframe(:,:,:,i) = read(trafficVideo, i);
            waitbar(i/numberFrames) %wait bar fills with each loop until finishd 
        end
        close(h); %once completed, the wait bar closes 
        
        street = median(iframe,4); %finds the median value of all the frames, left with just the street 
        
        %converts the first frame to a viewable image that shows the before
        %and after of the binary transformation to separate the cars from
        %the street background 
        iframeTest = iframe(:,:,:,1); 
        noBlobsTest = (abs(double(iframeTest) - double(street)))>20; % noBlobsTest is where the difference between the frame and just the street is above twenty 
        drawTest = [mat2gray(iframeTest),mat2gray(noBlobsTest)]; %puts the original frame and the new frame side by side 
        imagesc(drawTest); %shows the images side by side to the user 
        
        
        %prompts the user to choose a value
        userAnswer = 'No'; %ensures the loop continues until the user selects Yes 
        promptTwo = 'Please enter a value between 1 and 100 that most clearly defines the cars in the frame. The value has automatically been set to 20. A higher value results in less strength. The goal is that there are minimal to no gaps between the white figure of the car.';
        while (strcmpi(userAnswer,'No'))
            
            choiceTwo = inputdlg(promptTwo, 'Car Tracking Program', 1);
            data = str2double(choiceTwo{:}); %changes the users answer from a string into a number 
            noBlobsTest = (abs(double(iframeTest) - double(street)))>(data); %this number is used to modify the image
            drawTest = [mat2gray(iframeTest),mat2gray(noBlobsTest)]; %the modified image is put side by side with the original 
            imagesc(drawTest); %the image is shown to the user 
            
            %the user is asked if this is the value they want to use 
            choiceThree = questdlg('Is this the value you would like to use?',...
                 'Car Tracking Program', 'Yes', 'No', 'Yes');
            
            switch choiceThree
                case 'No' 
                    userAnswer = 'No'; %if the user selects No, the loop repeats so they can select a new value 
                case 'Yes' 
                    userAnswer = 'Yes'; %if the user selects Yes, userAnswer is now no longer No, so the loop breaks
            end
        end
        
        
        %bounding boxes are put around the figures with user specified
        %value 
        iframe1Test = iframe(:,:,:,1);
        noBlobs = (abs(double(iframe1Test) - double(street)))>(data); 
        st = regionprops(noBlobs,'BoundingBox', 'Area'); %bounding boxes created 
        
        data2 = 1000; %default value for the minimum area of bounding boxes plotted 
        iframe(:,:,:,1) = read(trafficVideo, 1);
        figure, imshow(iframe(:,:,:,1))
        hold on %ensures that all bounding boxes will be plotted
        for k = 1 : length(st)
            if st(k).Area > (data2) %as long as the area of the bounding box is greater than the defined amount, it will be plotted 
                rectangle('Position', st(k).BoundingBox([1,2,4,5]) ,'Edgecolor','g','LineWidth',2) %plots the bounding box with custom edge color and line width 
            else
            end
        end
        hold off
        
        userAnswer2 = 'No'; %default answer set to No so the loop can begin 
        promptFour = 'Please enter a value for the minimum area of each bounding box. The value has automatically been set to 1000. A higher value will ignore smaller boxes. Set this value until each car only has one box which is also as confined as possible. A usual value is around 450000.';
        while (strcmpi(userAnswer2,'No')) %as long as the users answer is no, the loop will continue 
            
            choiceFour = inputdlg(promptFour, 'Car Tracking Program', 1); %prompts the user to enter a value for the minimum area of the plotted bounding boxes 
            data2 = str2double(choiceFour{:}); %changes the string value entered by the user to a number 
            
            %now inserts the users value into the code and plots new
            %bounding boxes 
            iframe(:,:,:,1) = read(trafficVideo, 1);
            figure(1)
            imshow(iframe(:,:,:,1))
            hold on
            
            for k = 1 : length(st)
                if st(k).Area > (data2) %inserts the users value here 
                    rectangle('Position', st(k).BoundingBox([1,2,4,5]),...
                        'Edgecolor','g','LineWidth',2)
                else
                end
            end
            
            
            hold off
            
            %user is asked if they would like to use the value they defined
            choiceFive = questdlg('Is this the value you would like to use?',...
                'Car Tracking Program', 'Yes', 'No', 'Yes');
            
            switch choiceFive
                case 'No'
                    userAnswer2 = 'No'; %if the user selects No, userAnswer2 is No so the loop continues 
                case 'Yes'
                    userAnswer2 = 'Yes'; %if the user selects Yes, userAnswer2 is no longer No, so the loop breaks 
                    close figure 2 %figure 2 is closed 
            end
        end
        
        
        %asked the iser if they would like to view the data or exit 
        choiceSix = questdlg('Here is your data:', 'Car Tracking Program',...
            'View Visual and Graphical Data', 'Exit', 'View Visual and Graphical Data');
        switch choiceSix
            
            case 'View Visual and Graphical Data'
                
                figure1 = figure;
                axes1 = axes('Parent', figure1);
                hold(axes1, 'all');
                
                
                 %finds the number of cars in the frame every second
                 seconds = floor(numberFrames/frameRate); %finds the total number of seconds in the video, rounded down       
                 
                 %find the number of bouding boxes at each second mark 
                 numBoxes = zeros(1,seconds);  
                         for a = 1:seconds 
                             iframe1Test = iframe(:,:,:,((frameRate-(frameRate*2-1)) +(frameRate*a))); %selects the frame at each second mark 
                             noBlobs = (abs(double(iframe1Test) - double(street)))>(data);
                             st = regionprops(noBlobs,'BoundingBox', 'Area');
                             
                             for R = 1:size(st,1)
                                 if st(R).Area >= 45000
                                     numBoxes(a) = numBoxes(a) + 1;
                                 else
                                 end
                             end
                         end
                         
                        X = linspace(1,seconds,seconds); %X values are the number of seconds 
                        Y = numBoxes; %Y values are the calculated number of boundingboxes which is equal to the number of cars 
                        plot (X,Y,'k-s') %plots the data 
                       
                        %labels the graphs axis and title 
                        xlabel('Times (s)')
                        ylabel('Cars on Road Segment')
                        title('Number of Cars on Road per Second')
                        
                        axis auto
                        grid on

                
                saveas(figure1, 'TrackedCarsData.jpg') %saves the graph as a jpg 
                choiceFinal = questdlg('A copy of the graph has been saved on your device under "TrackedCarsData.jpg"',...
                    'Car Tracking Program', 'Ok', 'Exit', 'Ok'); %prompts the user that a copy has been saved 
                    switch choiceFinal
                        case 'Ok' %if they select Ok, the tracked cars will begin to play frame by frame 
                
                
                for i = 1:size(iframe,4)
                    iframe1 = iframe(:,:,:,i);
                    noBlobs = (abs(double(iframe1) - double(street)))>(data);
                    st = regionprops(noBlobs,'BoundingBox', 'Area');
                    
                    
                    
                    iframe(:,:,:,i) = read(trafficVideo, i);
                    figure(1)
                    imshow(iframe(:,:,:,i))
                    hold on
                    
                    for k = 1 : length(st)
                        if st(k).Area > (data2)
                            rectangle('Position', st(k).BoundingBox([1,2,4,5]) ,'Edgecolor','g','LineWidth',2)
                        else
                        end
                    end
                    hold off
                end
                
                        case 'Exit' %if the user selects Exit, the program ends 
                    end 
                
            case 'Exit' %if the user selects Exit, the program ends 
                
        end
        
        
    case 'Cancel' %if the user selects Cancel, the program ends 
        close ALL
        
end