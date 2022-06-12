classdef FitMeas < Meas
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

    properties(Access = protected)
        rsquare_
        sse_
    end

    methods(Access = public)
        function obj = FitMeas(value_, err_, rsquare_, sse_)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            obj = obj@Meas(value_, err_);
            obj.rsquare_ = rsquare_;
            obj.sse_ = sse_;
        end
        function conv = Meas(obj)
            conv = Meas.from(obj.value, obj.err);
        end
        function v = rsquare(obj)
            v = reshape([obj(:,1).rsquare_], size(obj, 1), 1);
        end
        function v = sse(obj)
            v = reshape([obj(:,1).sse_], size(obj, 1), 1);
        end
        function meas = slope(obj)
            meas = obj(:,1);
        end
        function meas = intercept(obj)
            meas = obj(:,2);
        end % N * 2
    end
    methods(Access = public, Static)
        function obj_list = from(sciFitObj)
            obj_list = repmat(FitMeas(1,1,1,1),size(sciFitObj, 1), 2);
            temp = num2cell(sciFitObj(:,1:2,1));
            [obj_list.value_] = temp{:};
            temp = num2cell(sciFitObj(:,1:2,2));
            [obj_list.err_] = temp{:};
            temp = num2cell(sciFitObj(:,1,4));
            [obj_list(:,1).rsquare_] = temp{:};
            [obj_list(:,2).rsquare_] = temp{:};
            temp = num2cell(sciFitObj(:,2,4));
            [obj_list(:,1).sse_] = temp{:};
            [obj_list(:,2).sse_] = temp{:};
        end
        function titleStruct = titles(title, x_axis, y_axis, data, fit)
            if size(fit,1) == 1
                fit = fit';
            end
            if size(data,1) == 1
                data = data';
            end
            titleStruct = struct('title', title, 'x_axis', x_axis,...
                'y_axis', y_axis, 'data', data, 'fit', fit);
        end
    end
end