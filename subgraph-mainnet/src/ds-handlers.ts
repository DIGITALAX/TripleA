import {
  Bytes,
  JSONValue,
  JSONValueKind,
  dataSource,
  json,
} from "@graphprotocol/graph-ts";
import {
  CollectionMetadata,
  AgentMetadata,
  DropMetadata,
  FulfillerMetadata,
} from "../generated/schema";

export function handleCollectionMetadata(content: Bytes): void {
  let metadata = new CollectionMetadata(dataSource.stringParam());
  const value = json.fromString(content.toString()).toObject();
  if (value) {
    let image = value.get("image");
    if (image && image.kind === JSONValueKind.STRING) {
      metadata.image = image.toString();
    }
    let title = value.get("title");
    if (title && title.kind === JSONValueKind.STRING) {
      metadata.title = title.toString();
    }
    let description = value.get("description");
    if (description && description.kind === JSONValueKind.STRING) {
      metadata.description = description.toString();
    }

    let sizes = value.get("sizes");
    if (sizes && sizes.kind === JSONValueKind.ARRAY) {
      metadata.sizes = sizes
        .toArray()
        .map<string>((target: JSONValue) => target.toString());
    }

    let colors = value.get("colors");
    if (colors && colors.kind === JSONValueKind.ARRAY) {
      metadata.colors = colors
        .toArray()
        .map<string>((target: JSONValue) => target.toString());
    }

    let format = value.get("format");
    if (format && format.kind === JSONValueKind.STRING) {
      metadata.format = format.toString();
    }

    let model = value.get("model");
    if (model && model.kind === JSONValueKind.STRING) {
      metadata.model = model.toString();
    }

    let prompt = value.get("prompt");
    if (prompt && prompt.kind === JSONValueKind.STRING) {
      metadata.prompt = prompt.toString();
    }

    metadata.save();
  }
}

export function handleAgentMetadata(content: Bytes): void {
  let metadata = new AgentMetadata(dataSource.stringParam());
  const value = json.fromString(content.toString()).toObject();
  if (value) {
    let cover = value.get("cover");
    if (cover && cover.kind === JSONValueKind.STRING) {
      metadata.cover = cover.toString();
    }
    let title = value.get("title");
    if (title && title.kind === JSONValueKind.STRING) {
      metadata.title = title.toString();
    }
    let bio = value.get("bio");
    if (bio && bio.kind === JSONValueKind.STRING) {
      metadata.bio = bio.toString();
    }

    let customInstructions = value.get("customInstructions");
    if (
      customInstructions &&
      customInstructions.kind === JSONValueKind.STRING
    ) {
      metadata.customInstructions = customInstructions.toString();
    }

    let style = value.get("style");
    if (style && style.kind === JSONValueKind.STRING) {
      metadata.style = style.toString();
    }

    let model = value.get("model");
    if (model && model.kind === JSONValueKind.STRING) {
      metadata.model = model.toString();
    }

    let knowledge = value.get("knowledge");
    if (knowledge && knowledge.kind === JSONValueKind.STRING) {
      metadata.knowledge = knowledge.toString();
    }

    let adjectives = value.get("adjectives");
    if (adjectives && adjectives.kind === JSONValueKind.STRING) {
      metadata.adjectives = adjectives.toString();
    }

    let lore = value.get("lore");
    if (lore && lore.kind === JSONValueKind.STRING) {
      metadata.lore = lore.toString();
    }

    let feeds = value.get("feeds");
    if (feeds && feeds.kind === JSONValueKind.ARRAY) {
      metadata.feeds = feeds
        .toArray()
        .filter((target: JSONValue) => target.kind === JSONValueKind.STRING)
        .map<string>((target: JSONValue) => target.toString());
    }

    let messageExamples = value.get("messageExamples");
    if (messageExamples && messageExamples.kind === JSONValueKind.ARRAY) {
      metadata.messageExamples = messageExamples
        .toArray()
        .map<string>((target: JSONValue) => target.toString());
    }

    metadata.save();
  }
}

export function handleDropMetadata(content: Bytes): void {
  let metadata = new DropMetadata(dataSource.stringParam());
  const value = json.fromString(content.toString()).toObject();
  if (value) {
    let cover = value.get("cover");
    if (cover && cover.kind === JSONValueKind.STRING) {
      metadata.cover = cover.toString();
    }
    let title = value.get("title");
    if (title && title.kind === JSONValueKind.STRING) {
      metadata.title = title.toString();
    }

    metadata.save();
  }
}

export function handleFulfillerMetadata(content: Bytes): void {
  let metadata = new FulfillerMetadata(dataSource.stringParam());
  const value = json.fromString(content.toString()).toObject();
  if (value) {
    let cover = value.get("cover");
    if (cover && cover.kind === JSONValueKind.STRING) {
      metadata.cover = cover.toString();
    }
    let title = value.get("title");
    if (title && title.kind === JSONValueKind.STRING) {
      metadata.title = title.toString();
    }

    let description = value.get("description");
    if (description && description.kind === JSONValueKind.STRING) {
      metadata.description = description.toString();
    }

    let link = value.get("link");
    if (link && link.kind === JSONValueKind.STRING) {
      metadata.link = link.toString();
    }

    metadata.save();
  }
}
