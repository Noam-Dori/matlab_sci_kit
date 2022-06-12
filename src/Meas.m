classdef Meas
    properties(Access = protected)
        value_
        err_
    end
    methods(Access = public)
        function obj = Meas(value_, err_)
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
            str = string(obj.value) + "±" + string(obj.err);
        end
        function disp(obj)
            disp_exponent = zeros(size(obj));
            err_exponent = zeros(size(obj));
            disp_exponent(obj.value ~= 0) = floor(log10(abs(obj(obj.value ~= 0).value)));
            err_exponent(obj.err ~= 0) = floor(log10(abs(obj(obj.err ~= 0).err)));
            err_disp = ceil(obj.err ./ (10 .^ err_exponent)) .* (10 .^ (err_exponent - disp_exponent));
            val_disp = round(obj.value ./ (10 .^ err_exponent)) .* (10 .^ (err_exponent - disp_exponent));
            cond = disp_exponent <= 2 & disp_exponent > 0;
            val_disp(cond) = val_disp(cond) .* (10 .^ disp_exponent(cond));
            err_disp(cond) = err_disp(cond) .* (10 .^ disp_exponent(cond));
            display = val_disp + "±" + err_disp;
            cond = disp_exponent > 2 | disp_exponent < 0;
            display(cond) = "(" + val_disp(cond) + "±" + err_disp(cond) + ")";
            display(obj.err == -1) = val_disp(obj.err == -1);
            display(obj.err == -2) = " ";
            cond = disp_exponent > 2 | disp_exponent < 0;
            display(cond) = display(cond) + "×10^" + disp_exponent(cond);
            disp(display);
        end
        function result = plus(l,r)
            if isa(l, "Meas") && isa(r, "Meas")
                syms pls(x,y)
                pls(x,y) = x + y;
                result = Meas.binary_apply(pls,l,r);
            elseif ~isa(r, "Meas")
                syms inc(x)
                inc(x) = x + r;
                result = Meas.unary_apply(inc, l);
            elseif ~isa(l, "Meas")
                result = r + l;
            end
        end
        function result = times(l,r)
            if isa(l, "Meas") && isa(r, "Meas")
                syms mul(x,y)
                mul(x,y) = x .* y;
                result = Meas.binary_apply(mul,l,r);
            elseif ~isa(r, "Meas")
                result = Meas.unary_apply(Meas.scalar(r), l);
            elseif ~isa(l, "Meas")
                result = r .* l;
            end
        end
        function result = rdivide(l,r)
            if isa(l, "Meas") && isa(r, "Meas")
                result = Meas.binary_apply(Meas.div,l,r);
            elseif ~isa(r, "Meas")
                result = Meas.unary_apply(Meas.scalar(1./r), l);
            elseif ~isa(l, "Meas")
                syms inve(x)
                inve(x) = l ./ x;
                result = Meas.unary_apply(inve, r);
            end
        end
        function result = power(l,r)
            if isa(l, "Meas") && isa(r, "Meas")
                if sum(size(r) ~= size(l)) > 0
                    [l,r] = Meas.matchsizes(l,r);
                end
                syms pw(x,y)
                pw(x,y) = x .^ y;
                result = Meas.binary_apply(pw,l,r);
            elseif ~isa(r, "Meas")
                syms pw(x)
                pw(x) = x .^ r;
                result = Meas.unary_apply(pw, l);
            elseif ~isa(l, "Meas")
                syms pw(x)
                pw(x) = l .^ x;
                result = Meas.unary_apply(pw, l);
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
        function result = vertcat(varargin)
            result = Meas.merge(varargin{:});
        end
        function result = horzcat(varargin)
            vertargin = cellfun(@transpose, varargin, 'UniformOutput', false);
            result = Meas.merge(vertargin{:})';
        end
        function result = isnan(obj_matrix)
            result = obj_matrix.err == -2;
        end
        function obj_list = apply(obj_matrix, f)
            [obj_val, obj_err] = errorf(f, obj_matrix.value, obj_matrix.err);
            obj_list = Meas.from(obj_val, obj_err);
            obj_list(max(Meas.remove(1,1).err == obj_matrix.err, [], 1)) = Meas.remove(1,1);
        end
        function result = uminus(obj_matrix)
            result = -1 * obj_matrix;
        end
        function result = log(obj_matrix)
            syms f(arg)
            f(arg) = log(arg);
            result = Meas.unary_apply(f, obj_matrix);
        end
        function result = exp(obj_matrix)
            syms f(arg)
            f(arg) = exp(arg);
            result = Meas.unary_apply(f, obj_matrix);
        end
        function result = sin(obj_matrix)
            syms f(arg)
            f(arg) = sin(arg);
            result = Meas.unary_apply(f, obj_matrix);
        end
        function result = tan(obj_matrix)
            syms f(arg)
            f(arg) = tan(arg);
            result = Meas.unary_apply(f, obj_matrix);
        end
        function result = cos(obj_matrix)
            syms f(arg)
            f(arg) = cos(arg);
            result = Meas.unary_apply(f, obj_matrix);
        end
        function result = sinh(obj_matrix)
            syms f(arg)
            f(arg) = sinh(arg);
            result = Meas.unary_apply(f, obj_matrix);
        end
        function result = tanh(obj_matrix)
            syms f(arg)
            f(arg) = tanh(arg);
            result = Meas.unary_apply(f, obj_matrix);
        end
        function result = cosh(obj_matrix)
            syms f(arg)
            f(arg) = cosh(arg);
            result = Meas.unary_apply(f, obj_matrix);
        end
        function result = asin(obj_matrix)
            syms f(arg)
            f(arg) = asin(arg);
            result = Meas.unary_apply(f, obj_matrix);
        end
        function result = atan(obj_matrix)
            syms f(arg)
            f(arg) = tan(arg);
            result = Meas.unary_apply(f, obj_matrix);
        end
        function result = acos(obj_matrix)
            syms f(arg)
            f(arg) = acos(arg);
            result = Meas.unary_apply(f, obj_matrix);
        end
        function result = asinh(obj_matrix)
            syms f(arg)
            f(arg) = asinh(arg);
            result = Meas.unary_apply(f, obj_matrix);
        end
        function result = atanh(obj_matrix)
            syms f(arg)
            f(arg) = atanh(arg);
            result = Meas.unary_apply(f, obj_matrix);
        end
        function result = acosh(obj_matrix)
            syms f(arg)
            f(arg) = acosh(arg);
            result = Meas.unary_apply(f, obj_matrix);
        end
        function result = sqrt(obj_matrix)
            syms f(arg)
            f(arg) = sqrt(arg);
            result = Meas.unary_apply(f, obj_matrix);
        end
        function result = abs(obj_matrix)
            result = obj_matrix;
            result.value = abs(result.value);
        end
        function result = atan2(l_obj, r_obj)
            syms f(l,r)
            f(l,r) = atan2(l,r);
            result = Meas.binary_apply(f, l_obj, r_obj);
        end
        function obj_list = mean(obj_matrix)
            [obj_val, obj_err] = stat_errorf('mean', obj_matrix.value, obj_matrix.err);
            obj_list = Meas.from(obj_val, obj_err);
        end
        function obj_list = sum(obj_matrix)
            [obj_val, obj_err] = stat_errorf('sum', obj_matrix.value, obj_matrix.err);
            obj_list = Meas.from(obj_val, obj_err);
        end
        function obj_list = diff(obj_matrix)
            [obj_val, obj_err] = stat_errorf('diff', obj_matrix.value, obj_matrix.err);
            obj_list = Meas.from(obj_val, obj_err);
        end
        function obj_list = mean_diff(obj_matrix)
            [obj_val, obj_err] = stat_errorf('mean_diff', obj_matrix.value, obj_matrix.err);
            obj_list = Meas.from(obj_val, obj_err);
        end
        function obj_list = integral(obj_matrix)
            [obj_val, obj_err] = stat_errorf('int', obj_matrix.value, obj_matrix.err);
            obj_list = Meas.from(obj_val, obj_err);
        end
        function obj_list = running_avg_2(obj_matrix)
            [obj_val, obj_err] = stat_errorf('running_avg_2', obj_matrix.value, obj_matrix.err);
            obj_list = Meas.from(obj_val, obj_err);
        end
    end
    methods(Static, Access = protected)
        function result = binary_apply(f, l, r)
            if sum(size(r) ~= size(l)) > 0
                [l,r] = Meas.matchsizes(l,r);
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
        function obj_list = from(values, errs)
            if(size(errs,1) == 1)
                errs = errs * ones(size(values,1),1);
            end
            if(size(errs,2) == 1)
                errs = errs * ones(1,size(values,2));
            end
            obj_list = zeros(size(values),'Meas');
            temp = num2cell(values);
            [obj_list.value_] = temp{:};
            temp = num2cell(errs);
            [obj_list.err_] = temp{:};
        end
        function obj_list = remove(varargin)
            obj_list = repmat(Meas(1,-2),varargin{:});
        end
        function z = zeros(varargin)
            if (nargin == 0)
                z = Meas;
            elseif any([varargin{:}] <= 0)
                z = Meas.empty(varargin{:});
            else
                z = repmat(Meas(0,1),varargin{:});
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
            if isa(x, "string")
                cat_graph(y, x, titles, 1);
            elseif isa(y, "string")
                cat_graph(x, y, titles, 0);
            else
                obj_list = FitMeas.from(sci_fit(x.value, y.value, x.err, y.err, titles));
            end
        end
        function obj_list = merge(varargin)
            size_arr = cellfun(@size,varargin,'UniformOutput',false);
            size_vec = reshape([size_arr{:}], 2, size(varargin, 2));
            target_size = [sum(size_vec(1,:)), max(size_vec(2,:))];
            obj_list = Meas.remove(target_size);
            dim1_iter = 0;
            arg_iter = 1;
            while dim1_iter < target_size(1)
                if isa(varargin{arg_iter},"symfun")
                    % take first "dim 2" element out of each "dim 1" row,
                    % and use its equation and the last N arguments before
                    % this equation block to determine the values.
                    for i = 1:size_arr{arg_iter}(1)
                        if isscalar(varargin{arg_iter})
                            func = varargin{arg_iter};
                        else
                            func = varargin{arg_iter}(i,1);
                        end
                        argsize = size(argnames(func), 2);
                        result = obj_list(dim1_iter-argsize+1:dim1_iter, 1:target_size(2)).apply(func);
                        obj_list(dim1_iter+i, 1:target_size(2)) = result;
                    end
                elseif isa(varargin{arg_iter},"double")
                    obj_list(dim1_iter+1:dim1_iter+size_arr{arg_iter}(1), ...
                        1:size_arr{arg_iter}(2)) = Meas.from(varargin{arg_iter},-1);
                else
                    obj_list(dim1_iter+1:dim1_iter+size_arr{arg_iter}(1), ...
                        1:size_arr{arg_iter}(2)) = varargin{arg_iter};
                end
                dim1_iter = dim1_iter + size_arr{arg_iter}(1);
                arg_iter = arg_iter + 1;
            end
        end
    end
end