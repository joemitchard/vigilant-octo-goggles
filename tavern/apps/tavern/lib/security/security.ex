defmodule Tavern.Security do
    
    @doc """
    Returns the combined hash of `a` and `b`
    """
    def hash(a, b) do
        sha256 a, b
    end

    @doc """
    Returns true if the combined hash of `a` and `b` matches `hash`
    """
    def is_match(a, b, hash) do
        hash === sha256 a, b
    end

    defp sha256(a, b) do
        :crypto.hash(:sha256, a <> b)
    end

end