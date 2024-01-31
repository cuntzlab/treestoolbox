function out = isBinary(x)

out = any([ismember(x, [0, 1]), islogical(x)]);

end