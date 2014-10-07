%
%  Created by Vahid Kazemi
%  Copyright (c) 2013 Vahid Kazemi. All rights reserved.
%
classdef Transform    
    methods (Static)        
        function T = create(varargin)
            if nargin<1, return; end;
            if isfloat(varargin{1})
                if(prod(single(size(varargin{1})==[2 2])))
                    T = eye(3,3);
                    T(1:2,1:2) = varargin{1};
                elseif(prod(single(size(varargin{1})==[3 3])))
                    T = eye(4,4);
                    T(1:3,1:3) = varargin{1};
                else
                    error('invalid arguments.');
                end
            elseif ischar(varargin{1})
                switch(varargin{1})
                    case 'r'
                        theta = varargin{2};
                        T = [cos(theta), -sin(theta), 0;...
                            sin(theta), cos(theta), 0;...
                            0, 0, 1];
                    case 'ra'
                        axis = varargin{2};
                        theta = varargin{3};
                        L = norm(axis);
                        axis = axis / L;
                        u = axis(1);
                        v = axis(2);
                        w = axis(3);
                        u2 = u^2;
                        v2 = v^2;
                        w2 = w^2;
                        c = cos(theta);
                        s = sin(theta);
                        T = zeros(4,4);
                        T(1,1) =  u2 + (v2 + w2)*c;
                        T(1,2) = u*v*(1-c) - w*s;
                        T(1,3) = u*w*(1-c) + v*s;
                        T(2,1) = u*v*(1-c) + w*s;
                        T(2,2) = v2 + (u2+w2)*c;
                        T(2,3) = v*w*(1-c) - u*s;
                        T(3,1) = u*w*(1-c) - v*s;
                        T(3,2) = v*w*(1-c)+u*s;
                        T(3,3) = w2 + (u2+v2)*c;
                        T(4,4) = 1;
                    case 't'
                        pos = varargin{2};
                        switch length(pos)
                            case 2
                                T = [1,0,0;...
                                    0,1,0;...
                                    pos(1), pos(2), 1];
                            case 3
                                T = [1,0,0,0;...
                                    0,1,0,0;...
                                    0,0,1,0;...
                                    pos(1), pos(2), pos(3), 1];
                        end
                    case 's'
                        scale = varargin{2};
                        switch length(scale)
                            case 2
                                T = [scale(1),0,0;...
                                    0,scale(2),0;...
                                    0,0,1];
                            case 3
                                T = [scale(1),0,0,0;...
                                    0,scale(2),0,0;...
                                    0,0,scale(3),0;...
                                    0,0,0,1];
                        end
                end
            else
                error('invalid arguments.');
            end
        end
        
        function tX = coords(X, T)
            tX = [X, ones(size(X,1),1)] * T;
            tX = tX(:,1:size(X,2))./repmat(tX(:,end),[1 size(X,2)]);
        end
    end
end
