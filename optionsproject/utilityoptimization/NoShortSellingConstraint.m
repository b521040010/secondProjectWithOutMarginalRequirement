classdef NoShortSellingConstraint < UtilityMaximizationConstraint
    %utility=-2.2558615
    properties
        
    end
    
    methods 
        
        function c = NoShortSellingConstraint()
            
        end
        
        function applyConstraint( c, utilityMaximizationSolver, geometricProblem ) 
        % Apply the constraint to the separable problem
            
            %Implement 0<=xj(t)=xj(t-1)+delxj(t)
            s = utilityMaximizationSolver;
            currentPortfolio=s.p.currentPosition;
            for idx=1:length(s.p.instruments)
                aaa=s.p.instruments(idx);
                assert(length(aaa)==1);
                name=aaa{1}.print;
                scale=1;
                %name=s.p.instruments(idx).print;
                idxPrePort=find(strcmp(keys(currentPortfolio.map),name));
                if idxPrePort>=0
                    tempp=values(currentPortfolio.map);
                    xtminus1=tempp{idxPrePort}.quantity*scale;
                else
                    xtminus1=0;
                end
                xtminus1;
                temp=zeros(1,s.nq+1);
                indices = find(s.indexToInstrument==idx);
                for idxx=indices                       
                        short = s.indexToShort(idxx);
                        if short
                            temp(idxx)=1*scale;
                        end
%                         if not(short)
%                             temp(idxx)=-1*scale;
%                         end      
                end    
                        geometricProblem.addLinearUpperBound(temp,xtminus1,'quantity constraint short');
            end
            %--------------------------------------------------------------
        end
        function rescale(c)
        end
            
            
    end
end