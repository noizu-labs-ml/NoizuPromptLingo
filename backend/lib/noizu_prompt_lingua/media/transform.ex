defmodule NoizuPromptLingua.Media.Transform do
  @max_dimension 4096
  @default_quality 85

  @content_types %{
    "jpg" => "image/jpeg",
    "jpeg" => "image/jpeg",
    "png" => "image/png",
    "webp" => "image/webp",
    "avif" => "image/avif"
  }

  @doc "Parse and validate transform params from query string"
  def parse_params(params) do
    %{
      w: clamp_dimension(params["w"]),
      h: clamp_dimension(params["h"]),
      f: validate_format(params["f"]),
      q: clamp_quality(params["q"]),
      fit: validate_fit(params["fit"])
    }
    |> Enum.reject(fn {_, v} -> is_nil(v) end)
    |> Map.new()
  end

  @doc "Check if any transform params are present"
  def has_transforms?(params), do: map_size(params) > 0

  @doc "Generate canonical param string for cache key"
  def canonical_params(params) do
    params
    |> Enum.sort_by(fn {k, _} -> Atom.to_string(k) end)
    |> Enum.map(fn {k, v} -> "#{k}=#{v}" end)
    |> Enum.join(",")
  end

  @doc "Generate S3 key for a variant"
  def variant_s3_key(original_key, params) do
    hash =
      :crypto.hash(:sha256, canonical_params(params))
      |> Base.hex_encode32(case: :lower, padding: false)
      |> binary_part(0, 12)

    format = Map.get(params, :f, ext_from_key(original_key))
    dir = Path.dirname(original_key)
    base = Path.basename(original_key, Path.extname(original_key))
    "#{dir}/variants/#{base}_#{hash}.#{format}"
  end

  @doc "Transform an image binary according to params"
  def transform(image_binary, params) do
    with {:ok, image} <- Vix.Vips.Image.new_from_buffer(image_binary) do
      image = resize(image, params)

      format = Map.get(params, :f, "jpg")
      quality = Map.get(params, :q, @default_quality)

      case write_to_format(image, format, quality) do
        {:ok, binary} ->
          {:ok, binary, content_type(format)}

        error ->
          error
      end
    end
  end

  defp resize(image, %{w: w, h: h} = params) do
    fit = Map.get(params, :fit, "cover")
    do_resize(image, w, h, fit)
  end

  defp resize(image, %{w: w} = params) do
    fit = Map.get(params, :fit, "inside")
    {_orig_w, orig_h} = image_dimensions(image)
    do_resize(image, w, orig_h, fit)
  end

  defp resize(image, %{h: h} = params) do
    fit = Map.get(params, :fit, "inside")
    {orig_w, _orig_h} = image_dimensions(image)
    do_resize(image, orig_w, h, fit)
  end

  defp resize(image, _params), do: image

  defp do_resize(image, w, h, fit) do
    {orig_w, orig_h} = image_dimensions(image)

    case fit do
      "cover" ->
        scale = max(w / orig_w, h / orig_h)
        {:ok, resized} = Vix.Vips.Operation.resize(image, scale)
        {:ok, cropped} = Vix.Vips.Operation.smartcrop(resized, w, h)
        cropped

      "contain" ->
        scale = min(w / orig_w, h / orig_h)
        {:ok, resized} = Vix.Vips.Operation.resize(image, scale)
        resized

      "fill" ->
        hscale = w / orig_w
        vscale = h / orig_h
        {:ok, resized} = Vix.Vips.Operation.resize(image, hscale, vscale: vscale)
        resized

      _ ->
        # "inside" / "outside"
        scale =
          if fit == "outside",
            do: max(w / orig_w, h / orig_h),
            else: min(w / orig_w, h / orig_h)

        {:ok, resized} = Vix.Vips.Operation.resize(image, scale)
        resized
    end
  end

  defp image_dimensions(image) do
    {:ok, w} = Vix.Vips.Image.width(image)
    {:ok, h} = Vix.Vips.Image.height(image)
    {w, h}
  end

  defp write_to_format(image, "jpg", quality),
    do: Vix.Vips.Image.write_to_buffer(image, ".jpg[Q=#{quality}]")

  defp write_to_format(image, "jpeg", quality),
    do: write_to_format(image, "jpg", quality)

  defp write_to_format(image, "png", _quality),
    do: Vix.Vips.Image.write_to_buffer(image, ".png")

  defp write_to_format(image, "webp", quality),
    do: Vix.Vips.Image.write_to_buffer(image, ".webp[Q=#{quality}]")

  defp write_to_format(image, "avif", quality),
    do: Vix.Vips.Image.write_to_buffer(image, ".avif[Q=#{quality}]")

  defp write_to_format(image, _, quality),
    do: write_to_format(image, "jpg", quality)

  defp clamp_dimension(nil), do: nil

  defp clamp_dimension(val) when is_binary(val) do
    case Integer.parse(val) do
      {n, ""} when n > 0 and n <= @max_dimension -> n
      _ -> nil
    end
  end

  defp clamp_quality(nil), do: nil

  defp clamp_quality(val) when is_binary(val) do
    case Integer.parse(val) do
      {n, ""} when n >= 1 and n <= 100 -> n
      _ -> nil
    end
  end

  defp validate_format(nil), do: nil
  defp validate_format(f) when f in ~w(jpg jpeg png webp avif), do: f
  defp validate_format(_), do: nil

  defp validate_fit(nil), do: nil
  defp validate_fit(f) when f in ~w(cover contain fill inside outside), do: f
  defp validate_fit(_), do: nil

  def content_type(format), do: Map.get(@content_types, format, "image/jpeg")

  defp ext_from_key(key) do
    case Path.extname(key) do
      "." <> ext -> String.downcase(ext)
      _ -> "jpg"
    end
  end
end
