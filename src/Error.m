classdef Error
    properties(Access = private)
        value_
        err_
    end
    methods(Access = public)
        function obj = Error(value_, err_)
            obj.value_ = value_;
            obj.err_ = err_;
        end
        function v = value(obj)
            v = reshape([obj.value_], size(obj));
        end
        function v = err(obj)
            v = reshape([obj.err_], size(obj));
        end
        function v = relative(obj)
            v = reshape([obj.err_] ./ [obj.value_], size(obj));
        end
        function str = string(obj)
            str = string(obj.value) + " ± " + string(obj.err);
        end
        function disp(obj)
            disp(string(obj))
        end
        function result = plus(l,r)
            if class(l) == "Error" && class(r) == "Error"
                syms pls(x,y)
                pls(x,y) = x + y;
                result = Error.binary_apply(pls,l,r);
            elseif class(r) ~= "Error"
                syms inc(x)
                inc(x) = x + r;
                result = Error.unary_apply(inc, l);
            elseif class(l) ~= "Error"
                result = r + l;
            end
        end
        function result = times(l,r)
            if class(l) == "Error" && class(r) == "Error"
                syms mul(x,y)
                mul(x,y) = x .* y;
                result = Error.binary_apply(mul,l,r);
            elseif class(r) ~= "Error"
                result = Error.unary_apply(Error.scalar(r), l);
            elseif class(l) ~= "Error"
                result = r .* l;
            end
        end
        function result = rdivide(l,r)
            if class(l) == "Error" && class(r) == "Error"
                result = Error.binary_apply(Error.div,l,r);
            elseif class(r) ~= "Error"
                result = Error.unary_apply(Error.scalar(1./r), l);
            elseif class(l) ~= "Error"
                syms inv(x)
                inv(x) = l ./ x;
                result = Error.unary_apply(inv, r);
            end
        end
        function result = power(l,r)
            if class(l) == "Error" && class(r) == "Error"
                if sum(size(r) ~= size(l)) > 0
                    [l,r] = Error.matchsizes(l,r);
                end
                syms pw(x,y)
                pw(x,y) = x .^ y;
                result = Error.binary_apply(pw,l,r);
            elseif class(r) ~= "Error"
                syms pw(x)
                pw(x) = x .^ r;
                result = Error.unary_apply(pw, l);
            elseif class(l) ~= "Error"
                syms pw(x)
                pw(x) = l .^ x;
                result = Error.unary_apply(pw, l);
            end
        end
        function result = mtimes(l,r)
            result = times(l,r);
        end
        function result = mrdivide(l,r)
            result = rdivide(l,r);
        end
        function result = ldivide(l,r)
            result = rdivide(l,r);
        end
        function result = mldivide(l,r)
            result = rdivide(l,r);
        end
        function result = mpower(l,r)
            result = power(l,r);
        end
        function result = minus(l,r)
            result = l + (-1 * r);
        end
        function result = eq(l,r)
            result = l.value == r.value && l.err == r.err;
        end
        function result = ne(l,r)
            result = ~(l == r);
        end
        function obj_list = apply(obj_matrix, f)
            [obj_val, obj_err] = errorf(f, obj_matrix.value, obj_matrix.err);
            obj_list = Error.from(obj_val, obj_err);
            obj_list(max(Error.remove(1,1).err == obj_matrix.err, [], 1)) = Error.remove(1,1);
        end
        function result = uminus(obj_matrix)
            result = -1 * obj_matrix;
        end
        function result = log(obj_matrix)
            syms f(arg)
            f(arg) = log(arg);
            result = Error.unary_apply(f, obj_matrix);
        end
        function result = exp(obj_matrix)
            syms f(arg)
            f(arg) = exp(arg);
            result = Error.unary_apply(f, obj_matrix);
        end
        function result = sin(obj_matrix)
            syms f(arg)
            f(arg) = sin(arg);
            result = Error.unary_apply(f, obj_matrix);
        end
        function result = tan(obj_matrix)
            syms f(arg)
            f(arg) = tan(arg);
            result = Error.unary_apply(f, obj_matrix);
        end
        function result = cos(obj_matrix)
            syms f(arg)
            f(arg) = cos(arg);
            result = Error.unary_apply(f, obj_matrix);
        end
        function obj_list = mean(obj_matrix)
            [obj_val, obj_err] = stat_errorf('mean', obj_matrix.value, obj_matrix.err);
            obj_list = Error.from(obj_val, obj_err);
        end
        function obj_list = sum(obj_matrix)
            [obj_val, obj_err] = stat_errorf('sum', obj_matrix.value, obj_matrix.err);
            obj_list = Error.from(obj_val, obj_err);
        end
        function obj_list = diff(obj_matrix)
            [obj_val, obj_err] = stat_errorf('diff', obj_matrix.value, obj_matrix.err);
            obj_list = Error.from(obj_val, obj_err);
        end
        function obj_list = mean_diff(obj_matrix)
            [obj_val, obj_err] = stat_errorf('mean_diff', obj_matrix.value, obj_matrix.err);
            obj_list = Error.from(obj_val, obj_err);
        end
        function obj_list = integral(obj_matrix)
            [obj_val, obj_err] = stat_errorf('int', obj_matrix.value, obj_matrix.err);
            obj_list = Error.from(obj_val, obj_err);
        end
        function obj_list = running_avg_2(obj_matrix)
            [obj_val, obj_err] = stat_errorf('running_avg_2', obj_matrix.value, obj_matrix.err);
            obj_list = Error.from(obj_val, obj_err);
        end
    end
    methods(Static, Access = protected)
        function result = binary_apply(f, l, r)
            if sum(size(r) ~= size(l)) > 0
                [l,r] = Error.matchsizes(l,r);
            end
            dims = size(size(l),2);
            result = permute(cat(dims + 1, l, r), [dims + 1, 1:dims]).apply(f);
            result = reshape(result, size(l));
        end
        function result = unary_apply(f, obj)
            dims = size(size(obj),2);
            result = permute(obj, [dims + 1, 1:dims]).apply(f);
            result = reshape(result, size(obj));
        end
    end
    methods(Static, Access = public)
        function obj_list = from(values, errors)
            if(size(errors,1) == 1)
                errors = errors * ones(size(values,1),1);
            end
            if(size(errors,2) == 1)
                errors = errors * ones(1,size(values,2));
            end
            obj_list = zeros(size(values),'Error');
            temp = num2cell(values);
            [obj_list.value_] = temp{:};
            temp = num2cell(errors);
            [obj_list.err_] = temp{:};
        end
        function obj_list = remove(varargin)
            obj_list = repmat(Error(1,-2),varargin{:});
        end
        function z = zeros(varargin)
            if (nargin == 0)
                z = Error;
            elseif any([varargin{:}] <= 0)
                z = Error.empty(varargin{:});
            else
                z = repmat(Error(0,1),varargin{:});
            end
        end
        function [l,r] = matchsizes(l,r)
            if size(l,1) == 1
                l = repmat(l,size(r,1), 1);
            end
            if size(l,2) == 1
                l = repmat(l, 1, size(r,2));
            end
            if size(r,1) == 1
                r = repmat(r,size(l,1), 1);
            end
            if size(r,2) == 1
                r = repmat(r, 1, size(l,2));
            end
        end
        function f = scalar(num)
            syms f(arg)
            f(arg) = num .* arg;
        end
        function f = div
            syms f(x,y)
            f(x,y) = x ./ y;
        end
        function obj_list = fit(x, y, titles)
            fit_obj = sci_fit(x.value, y.value, x.err, y.err, titles);
            obj_list = Error.from(fit_obj(:,1:2,1), fit_obj(:,1:2,2));
        end
        function obj_list = merge(varargin)
            size_arr = cellfun(@size,varargin,'UniformOutput',false);
            size_vec = reshape([size_arr{:}], 2, size(varargin, 2));
            target_size = [sum(size_vec(1,:)), max(size_vec(2,:))];
            obj_list = Error.remove(target_size);
            dim1_iter = 0;
            arg_iter = 1;
            while dim1_iter < target_size(1)
                obj_list(dim1_iter+1:dim1_iter+size_arr{arg_iter}(1), ...
                    1:size_arr{arg_iter}(2)) = varargin{arg_iter};
                dim1_iter = dim1_iter + size_arr{arg_iter}(1);
                arg_iter = arg_iter + 1;
            end
        end
    end
end