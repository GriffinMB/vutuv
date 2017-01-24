defmodule Vutuv.SlugHelpers do
	import Ecto.Query
	alias Vutuv.Repo

	@short_SHA_length 8

	def gen_slug(resource, char) do
		#The resource is expected to be a struct that implements String.Chars
    Slugger.slugify_downcase resource, char
	end

	def gen_slug_unique(resource, slug_field), do: gen_slug_unique resource, resource.__struct__, slug_field

	def gen_slug_unique(resource, model, slug_field, char \\ ?.) do
		slug = gen_slug resource, char
		Repo.one(from s in model,
      where: field(s, ^slug_field) == ^slug,
      limit: 1,
      select: field(s, ^slug_field))
		|> ensure_slug(slug, resource)
	end

	defp ensure_slug(nil, "", resource), do: to_string(resource)

	defp ensure_slug(nil, slug, _), do: slug

	defp ensure_slug(_, "", resource), do: "#{to_string(resource)}.#{short_sha}"

	defp ensure_slug(_, slug, _), do: "#{slug}.#{short_sha}"

	def short_sha do
		string = 
			:calendar.universal_time
			|> :calendar.datetime_to_gregorian_seconds
			|> Integer.to_string
		rand =
			:rand.uniform
			|> Float.to_string
		:crypto.hash(:sha256, string<>rand)
		|> Base.encode16
    |> String.downcase
		|> String.slice(0, @short_SHA_length)
	end
end