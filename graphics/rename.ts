//krite can't help it self but add 0 to the start of file names
for await (const dirEntry of Deno.readDir(".")) {
  if (dirEntry.isFile && dirEntry.name.endsWith(".png")) {
    const originalName = dirEntry.name;
    const nameWithoutExtension = originalName.slice(0, -4); // Remove ".png"
    
    // Remove leading zeros using regex
    const newNameWithoutExtension = nameWithoutExtension.replace(/^0+/, "") || "0";
    const newName = `${newNameWithoutExtension}.png`;

    // Skip if names are the same
    if (originalName === newName) continue;

    try {
      await Deno.rename(originalName, newName);
      console.log(`Renamed: ${originalName} -> ${newName}`);
    } catch (err) {
      console.error(`Failed to rename ${originalName}:`, err);
    }
  }
}
