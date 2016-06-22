macro "Image Registration" 
{
	currentPath = getArgument;
	if (currentPath=="") exit("No Given Path");
	run("Image Sequence...", "open=" + currentPath + " sort");
	run("StackReg ", "transformation=[Rigid Body]");		
	close();
	run("Quit");
}